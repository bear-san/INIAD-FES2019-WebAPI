class UserController < ApplicationController
  def new
    if params["device_type"].present? then
      render json:{"status" => "error", "description" => "device_type is required"},status:400
      return
    end

    user = User.new
    user.user_id = SecureRandom.uuid
    user.secret = SecureRandom.alphanumeric(32)
    user.role = ["participant"]

    user.save()

    render json:{"status" => "success", "secret" => user.secret, "role" => user.role}
    return
  end
end
