class VisitorController < ApplicationController
  #before_action :authentication, :except => [:in_venue_registration]
  protect_from_forgery :only => :all

  def in_venue_registration
    # 属性登録（会場で）

  end

  def in_app_registration
    # 属性登録（アプリ経由）

  end

  def reception
    # 来場受付（アプリ経由）
    if !(@user.role & ["developer","system_admin","fes_admin","fes_committee"]).present? then
      render json:{"status" => "error", "description" => "permission denied"},status:403
      return
    end

    begin
      user = User.find_by_user_id(params["user_id"])

      if !UserAttribute.find_by_user_name(user.user_id).present? then
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
    if !(@user.role.include & ["developer","system_admin","fes_admin","fes_committee"]).present? and !organizer.members.include?(@user.user_id) then
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
end
