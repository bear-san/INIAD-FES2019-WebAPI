class VisitorController < ApplicationController
  before_action :authentication, :except => [:in_venue_registration]
  protect_from_forgery :only => :all

  def in_venue_registration
    # 属性登録（会場で）

  end

  def in_app_registration
    # 属性登録（アプリ経由）
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
    if !(@user.role & ["developer","system_admin","fes_admin","fes_committee"]).present? and !organizer.members.include?(@user.user_id) then
      render json:{"status" => "error", "description" => "permission denied"},status:403
      return
    end

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
