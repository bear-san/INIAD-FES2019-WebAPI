class ApplicationController < ActionController::Base
  protect_from_forgery :except => [:not_found]

  def authentication
    begin
      token = request.headers["Authorization"]
      user = User.find_by_secret(/Bearer (.*)/.match(token)[1])

      if !user.present? then
        raise()
      end

    rescue
      render json:{"status" => "error", "description" => "authorization failed"},status:403
      return
    end

    @user = user
  end

  def not_found
    render json:{"status" => "error", "description" => "not found"},status:404
  end
end
