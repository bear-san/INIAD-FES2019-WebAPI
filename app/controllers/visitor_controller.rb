class VisitorController < ApplicationController
  before_action :authentication, :except => [:in_venue_registration, :register_attribute_form, :register_attribute]
  protect_from_forgery :only => :all

  def in_venue_registration
    # 属性登録（会場で）

  end

  def in_app_registration
    # 属性登録（アプリ経由）
    # MARK:廃止予定
    if @user.role.include?("visitor") then
      render json:{"status" => "error", "description" => "visitor attribute has already registered"},status:409
      return
    end

    if !params["gender"].present? or !params["age"].present? or !params["job"].present? or !params["number_of_people"].present? then
      render json:{"status" => "error", "description" => "parameter missing"},status:400
      return
    end

    new_attribute = VisitorAttribute.new
    new_attribute.user_id = @user.user_id
    new_attribute.action_history = {
        "visit" => []
    }
    new_attribute.visitor_attribute = {
        "gender" => params["gender"],
        "age" => params["age"],
        "job" => params["job"],
        "number_of_people" => params["number_of_people"]
    }

    new_attribute.save()

    render json:{"status" => "success", "description" => "register attribute has been successfully", "visitor_code" => @user.user_id}
    return
  end

  def register_attribute_form

  end

  def register_attribute
    user = User.find_by_secret(Digest::SHA256.hexdigest(params[:api_key]))
    if !user.present? then
      flash[:error] = "danger:無効なAPIキーです"
      redirect_to request.referer
      return
    end

    if VisitorAttribute.find_by_user_id(user.user_id).present? then
      if !user.role.include?("visitor") then
        user.role.append("visitor")
        user.save()
      end
      flash[:error] = "warning:既に属性情報が登録されています"
      redirect_to "iniadfes://open/renew-permission"
      return
    end

    new_attribute = VisitorAttribute.new
    new_attribute.user_id = user.user_id
    new_attribute.action_history = {
        "visit" => []
    }
    new_attribute.visitor_attribute = {
        "gender" => params["gender"],
        "age" => params["age"],
        "job" => params["job"],
        "number_of_people" => params["number_of_people"]
    }

    new_attribute.save()
    user.role.append("visitor")
    user.save()

    #権限情報を更新するよう指示する
    redirect_to "iniadfes://open/renew-permission"
  end

  def reception
    # 来場受付（アプリ経由）
    if !(@user.role & ["developer","system_admin","fes_admin","fes_committee"]).present? then
      render json:{"status" => "error", "description" => "permission denied"},status:403
      return
    end

    begin
      user = User.find_by_user_id(params["user_id"])

      if !VisitorAttribute.find_by_user_id(user.user_id).present? then
        render json:{"status" => "error", "description" => "Specified user isn't register user attributes."},status:400
        return
      end
    rescue
      render json:{"status" => "error", "description" => "could not find user form specified user_id"},status:404
      return
    end


    user.is_visited = true
    user.role.append("visitor")
    user.save()

    render json:{"status" => "success", "description" => "visitor reception has been successfull, welcome to INIAD-FES!"},status:200
    return
  end

  def entry_event
    # 各企画への来場受付

    if !params["user_id"].present? then
      render json:{"status" => "error", "description" => "target user_id must be specified"},status:400
      return
    end

    content = Content.find_by_ucode(params[:ucode])
    if !content.present? then
      render json:{"status" => "error", "description" => "not found"},status:404
      return
    end

    organizer = Organization.find_by_ucode(content.organizer)
    request_user = FesUser.where("devices @> ARRAY[?]::varchar[]",[@user.user_id]).first()
    if !request_user.present? then
      render json:{"status" => "error", "description" => "permission denied", "reason" => "Specified User isn't register to INIAD FES System"},status:403
      return
    end

    if organizer.members.include?(request_user.iniad_id) or (@user.role & ["developer","system_admin","fes_admin","fes_committee"]).present? then
      visitor_attribute = VisitorAttribute.find_by_user_id(params["user_id"])
      if !visitor_attribute.present? then
        render json:{"status" => "error", "description" => "Specified visitor isn't register attributes"},status:400
        return
      end

      timestamp = Time.now
      visitor_attribute.action_history["visit"].append({"ucode" => content.ucode, "timestamp" => timestamp})

      visitor_attribute.save()

      render json:{"status" => "success", "description" => "visitor entry process has been successfully", "timestamp" => timestamp}
      return
    else
      render json:{"status" => "error", "description" => "permission denied", "reason" => "Specified User isn't register to organization"},status:403
      return
    end
  end

  def dump_data
    if !params["user_id"].present? then
      data = VisitorAttribute.find_by_user_id(@user.user_id)

      if data.present? then
        render json:{"status" => "success","user_id" => @user.user_id , "role" => @user.role, "history" => data.action_history, "attribute" => data.visitor_attribute}
        return
      else
        render json:{"status" => "success", "role" => @user.role, "history" => nil, "attribute" => nil},status:200
        return
      end
    end

    if (@user.role & ["developer","system_admin","fes_admin"]).present? then
      # 管理者が特定のユーザーのアクティビティを表示する場合
      data = VisitorAttribute.find_by_user_id(params["user_id"])
      user = User.find_by_user_id(params["user_id"])

      if data.present? then
        render json:{"status" => "success","role" => user.role, "history" => data.action_history, "attribute" => data.visitor_attribute}
        return
      else
        render json:{"status" => "success", "role" => user.role, "history" => nil, "attribute" => nil},status:200
        return
      end
    else
      render json:{"status" => "error", "description" => "permission denied"},status:403
      return
    end
  end
end
