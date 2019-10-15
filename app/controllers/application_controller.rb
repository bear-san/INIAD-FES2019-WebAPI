require 'devise'
class ApplicationController < ActionController::Base
  include Devise::Controllers::SignInOut
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

  def check_sign_in_status
    if signed_in? then
      return
    end

    puts "not signed_in"
    session[:current_access] = request.fullpath
    redirect_to "/auth/g"
    return
  end

  def check_fesadmin_permission
    if !(current_fes_user.role & ["Developer","FesAdmin","OrganizationAdmin"]).present? then
      flash[:error] = "danger:機能へのアクセス権限がありません"
      redirect_to "/admin"
      return
    end
  end

  def check_developer_permission
    if !(current_fes_user.role & ["Developer"]).present? then
      flash[:error] = "danger:機能へのアクセス権がありません"
      redirect_to "/admin"
      return
    end
  end
end
