class VisitorController < ApplicationController
  before_action :authentication, :except => [:in_venue_registration, :register_attribute_form, :register_attribute, :final_enquete, :new_final_enquete]
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
      visitor_attribute = VisitorAttribute.find_by_user_id(user.user_id)
      if !visitor_attribute.present? then
        render json:{"status" => "error", "description" => "Specified user isn't register user attributes."},status:400
        return
      end
    rescue
      render json:{"status" => "error", "description" => "could not find user form specified user_id"},status:404
      return
    end


    user.is_visited = true
    user.role.append("visited_participant")

    date_stamp = Time.now.in_time_zone("Tokyo").strftime("%Y-%m-%d")
    if !visitor_attribute.visited_at.include?(date_stamp) then
      visitor_attribute.visited_at.append(date_stamp)
    end

    user.save()
    visitor_attribute.save()

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

  def final_enquete

  end

  def new_final_enquete
    attribute = VisitorAttribute.find_by_user_id(params[:user_id])
    attribute.enquete = {
        "satisfaction_level" => params["satisfaction_level"],
        "satisfaction_yes_reason" => params["satisfaction_yes_reason"],
        "satisfaction_no_reason" => params["satisfaction_no_reason"],
        "best_content" => params["best_content"],
        "next_year" => params["next_year"],
        "home_area" => params["home_area"],
        "group_member" => params["group_member"],
        "how_know" => params["how_know"]
    }

    attribute.save()

    redirect_to "/visitor/final-enquete?user_id=#{params[:user_id]}"
  end

  def migration
    before_attribute = VisitorAttribute.find_by_user_id(params[:before_user])
    after_attribute = VisitorAttribute.find_by_user_id(params[:after_user])

    if !before_attribute.present? or !after_attribute.present? then
      render json:{"status" => "error", "description" => "Specified attribute is not found, please check requested both user_id"}, status:404
      return
    end

    before_attribute.user_id = after_attribute.user_id
    before_attribute.save()

    after_attribute.destroy

    render json:{"status" => "success", "description" => "migration is successfully"}
  end

  def destroy_attribute
    if !@user.role.include?("developer") then
      render json:{"status" => "error", "description" => "permission denied."},status:403
      return
    end

    attribute = VisitorAttribute.find_by_user_id(params[:user_id])
    if !attribute.present? then
      render json:{"status" => "error", "description" => "specified attribute is not found."},status:404
      return
    end

    attribute.destroy

    render json:{"status" => "success", "description" => "delete has been successfully"}
  end
end
