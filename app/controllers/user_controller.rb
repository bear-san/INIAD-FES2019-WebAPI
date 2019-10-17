class UserController < ApplicationController
  before_action :authentication, :except => [:new]
  protect_from_forgery :except => [:new,:update_notification_token]

  def new
    if !params["device_type"].present? then
      render json:{"status" => "error", "description" => "device_type is required"},status:400
      return
    end

    user = User.new
    user.user_id = SecureRandom.uuid
    user.secret = SecureRandom.alphanumeric(32)
    user.role = ["app_user"]
    user.device_type = params["device_type"]

    user.save()

    render json:{"status" => "success", "secret" => user.secret, "role" => user.role}
    return
  end

  def update_notification_token
    if !params["device_token"].present? then
      render json:{"status" => "error", "description" => "required parameters missing"},status:400
      return
    end

    user = User.find_by_user_id(@user.user_id)
    user.notification_token = params["device_token"]

    user.save()

    render json:{"status" => "success", "description" => "notification token update has been successfully"}
  end

  def dump_data
    begin
      fes_user = FesUser.where("devices @> ARRAY[?]::varchar[]", [@user.user_id]).first()
      circle_object = Organization.where("members @> ARRAY[?]::varchar[]",[fes_user.iniad_id])
      circle_list = []
      circle_object.each do |circle|
        circle_list.append({"ucode" => circle.ucode, "organization_name" => circle.organization_name})
      end
    rescue
      render json:{"status" => "error", "description" => "internal server error"},status:500
      return
    end

    render json:{"status" => "success", "role" => @user.role, "member_of" => circle_list}
    return
  end
end
