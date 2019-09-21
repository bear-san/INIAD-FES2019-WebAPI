class ApplicationController < ActionController::Base
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
end
