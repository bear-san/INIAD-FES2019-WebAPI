class UserController < ApplicationController
  before_action :authentication, :except => [:new]
  protect_from_forgery :except => [:new,:update_notification_token]

  def new
    if params["device_type"].present? then
      render json:{"status" => "error", "description" => "device_type is required"},status:400
      return
    end

    user = User.new
    user.user_id = SecureRandom.uuid
    user.secret = SecureRandom.alphanumeric(32)
    user.role = ["participant"]
    user.device_type = params["device_type"]

    user.save()

    render json:{"status" => "success", "secret" => user.secret, "role" => user.role}
    return
  end

  def update_notification_token
    if params["device_token"].present? then
      render json:{"status" => "error", "description" => "required parameters missing"},status:400
    end

    user = User.find_by_user_id(@user.user_id)
    user.notification_token = params["device_token"]

    user.save()

    render json:{"status" => "success", "description" => "notification token update has been successfully"}
  end
end
