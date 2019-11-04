require "net/http"
require "open-uri"
require "base64"
require "devise"
require "digest/sha2"

class AdminController < ApplicationController
  include Devise::Controllers::SignInOut
  before_action :check_sign_in_status, :except => [:auth, :auth_callback, :sign_out]
  before_action :check_fesadmin_permission, :only => [
      :index,
      :show_contents,
      :create_contents_page,
      :show_organizer,
      :create_organizer_page,
      :edit_organizer_page
  ]
  before_action :check_developer_permission, :only => [
      :show_users_page,
      :create_users_page,
      :edit_users_page
  ]

  def index
    redirect_to "/admin/contents"
  end

  def auth
    sign_out
    redirect_to "https://accounts.google.com/o/oauth2/auth?client_id=#{ENV["GOOGLE_OAUTH_CLIENTID"]}&redirect_uri=#{ENV["SERVER_HOST"]}%2Fauth%2Fg%2Fcallback&response_type=code&scope=openid%20email%20profile&hd=iniad.org"
  end

  def auth_callback
    url = "https://accounts.google.com/o/oauth2/token"
    uri = URI.parse(url)
    req_parameter = {
        "code" => params["code"],
        "client_id" => ENV["GOOGLE_OAUTH_CLIENTID"],
        "client_secret" => ENV["GOOGLE_OAUTH_SECRET"],
        "grant_type" => "authorization_code",
        "redirect_uri" => "#{ENV["SERVER_HOST"]}/auth/g/callback"
    }

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(req_parameter)

    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    response = http.start do |http|
      http.use_ssl = true
      http.request(request)
    end

    response_json_object = JSON(response.body)
    id_token = JSON(Base64.decode64(response_json_object["id_token"].split(".")[1]))
    if id_token["hd"] != "iniad.org" then
      render plain:"システムアクセス権がありません。"
      return
    end

    access_token = response_json_object["access_token"]
    userinfo = JSON(open("https://www.googleapis.com/oauth2/v1/userinfo?access_token=#{access_token}").read)

    user = FesUser.find_by_iniad_id(userinfo["email"].split("@")[0])
    if !user.present? then
      render plain:"システムアクセス権がありません。"
      return
    end

    user.name = userinfo["name"]
    user.save()

    current_access = cookies[:current_access]
    cookies.delete(:current_access)
    sign_in user
    if current_access.present? then
      redirect_to current_access
      return
    else
      redirect_to "/admin"
      return
    end
  end

  def show_contents
    @contents = Content.all.order(:id)
  end

  def create_contents_page
    render template: "admin/create_contents"
  end

  def create_contents
    content = Content.new

    if !params["title"].present? or !params["organizer"].present? or !params["place"].present? or !params["description"].present? then
      flash[:error] = "danger:記載項目は全て必須事項です"
      redirect_to request.referer
      return
    end

    content.title = params["title"]

    if !Organization.find_by_ucode(params["organizer"]).present? then
      flash[:error] = "danger:不正な組織です"
      redirect_to request.referer
      return
    end
    content.organizer = params["organizer"]

    if !Room.where("ucode @> ARRAY[?]::varchar[]",[params["place"]]).present? then
      flash[:error] = "danger:不正な部屋です"
      redirect_to request.referer
      return
    end

    ucode = Ucode.where(:allocated => false).first()

    content.place = params["place"]
    content.description = params["description"]
    content.image_url = params["image-url"]
    content.ucode = ucode.ucode #未割り当てucodeのうち、適当なものを割り当てる

    content.save()
    ucode.allocated = true
    ucode.save()

    flash[:error] = "success:登録が完了しました"
    redirect_to "/admin/contents"
  end

  def edit_contents
    @content = Content.find_by_ucode(params[:ucode])

    if !@content.present? then
      flash[:error] = "danger:該当する企画がありません"
    end
  end

  def update_contents
    content = Content.find_by_ucode(params[:ucode])
    if !content.present? then
      flash[:error] = "danger:該当する企画がありません"
      redirect_to request.referer
      return
    end

    if !params["title"].present? or !params["organizer"].present? or !params["place"].present? or !params["description"].present? then
      flash[:error] = "danger:記載項目は全て必須事項です"
      redirect_to request.referer
      return
    end

    content.title = params["title"]

    if !Organization.find_by_ucode(params["organizer"]).present? then
      flash[:error] = "danger:不正な組織です"
      redirect_to request.referer
      return
    end
    content.organizer = params["organizer"]

    if !Room.where("ucode @> ARRAY[?]::varchar[]",[params["place"]]).present? then
      flash[:error] = "danger:不正な部屋です"
      redirect_to request.referer
      return
    end
    content.place = params["place"]
    content.description = params["description"]
    content.image_url = params["image-url"]

    content.save()
    flash[:error] = "success:更新が完了しました"

    redirect_to "/admin/contents"
  end

  def show_organizer
    @organizations = Organization.all.order(:id)
  end

  def create_organizer_page
    render template: "admin/create_organizer"
  end

  def create_organizer
    if !params["organization_name"].present?
      flash[:error] = "warning:組織名は入力必須です"
      redirect_to request.referer
      return
    end
    ucode = Ucode.where(:allocated => false).first()

    new_organization = Organization.new
    new_organization.ucode = ucode.ucode
    new_organization.organization_name = params["organization_name"]
    new_organization.members = []

    if params["members"].present? then
      JSON(params["members"]).each do |member|
        new_organization.members.append(member["value"])
      end
    end

    new_organization.save()
    ucode.allocated = true
    ucode.save()

    flash[:error] = "success:登録が完了しました"
    redirect_to "/admin/organizations"
  end

  def edit_organizer
    data = Organization.find_by_ucode(params[:patch_to])
    if !data.present? then
      flash[:error] = "danger:不正な値が含まれています"
      redirect_to request.referer
      return
    end

    if !params["organization_name"].present? then
      flash[:error] = "warning:組織名を空欄にすることはできません"
      redirect_to request.referer
      return
    end

    data.organization_name = params["organization_name"]
    data.members = []

    if params["members"].present? then
      JSON(params["members"]).each do |member|
        data.members.append(member["value"])
      end
    end

    data.save()

    flash[:error] = "success:更新が完了しました"
    redirect_to "/admin/organizations"
  end

  def edit_organizer_page
    @organization = Organization.find_by_ucode(params[:ucode])
    if !@organization.present? then
      flash[:error] = "danger:該当する組織が存在しません"
    end

    render template: "admin/edit_organizer"
  end

  def show_users_page
    @users = FesUser.all

    render template: "admin/show_users"
  end

  def create_users_page
    render template: "admin/create_users"
  end

  def create_users
    if !params["iniad_id"].present? then
      flash[:error] = "warning:INIAD IDを空欄にすることはできません"
      redirect_to request.referer
      return
    end

    data = FesUser.new
    data.iniad_id = params["iniad_id"]
    data.password = SecureRandom.alphanumeric(32)
    data.email = "#{params["iniad_id"]}@iniad.org"
    if !params["role"].present? then
      flash[:error] = "warning:権限は必ず１つ以上設定してください"
      redirect_to request.referer
      return
    end

    data.role = []

    JSON(params["role"]).each do|role|
      data.role.append(role["permission"])
    end

    data.save()

    flash[:error] = "success:登録が完了しました"
    redirect_to "/admin/users"
  end

  def edit_users_page
    @user = FesUser.find_by_iniad_id(params[:iniad_id])
    if !@user.present? then
      flash[:error] = "danger:該当するユーザーが存在しません"
    end

    render template: "admin/edit_users"
  end

  def edit_users
    data = FesUser.find_by_iniad_id(params["patch_to"])
    if !data.present? then
      flash[:error] = "danger:該当するユーザーが存在しません"
      redirect_to request.referer
      return
    end

    if !params["iniad_id"].present? then
      flash[:error] = "warning:INIAD IDを空欄にすることはできません"
      redirect_to request.referer
      return
    end

    data.iniad_id = params["iniad_id"]
    data.password = SecureRandom.alphanumeric(32)
    data.email = "#{params["iniad_id"]}@iniad.org"
    if !params["role"].present? then
      flash[:error] = "warning:権限は必ず１つ以上設定してください"
      redirect_to request.referer
      return
    end
    data.role = []

    JSON(params["role"]).each do|role|
      data.role.append(role["permission"])
    end

    data.save()

    flash[:error] = "success:登録が完了しました"
    redirect_to "/admin/users"
  end

  def app_auth
    target_device = User.find_by_secret(Digest::SHA256.hexdigest(params["api_key"]))
    if !target_device.present? then
      redirect_to "iniadfes://open/renew-permission"
      return
    end
    target_user = FesUser.find_by_iniad_id(current_fes_user.iniad_id)

    if !target_user.devices.include?(target_device.user_id) then
      target_user.devices.append(target_device.user_id)
    end

    if target_user.role.include?("Developer") and !target_device.role.include?("developer") then
      target_device.role.append("developer")
    end

    if target_user.role.include?("FesCommittee") and !target_device.role.include?("fes_admin") then
      target_device.role.append("fes_admin")
    end

    if !target_device.role.include?("circle_participant") then
      target_device.role.append("circle_participant")
    end

    target_user.save()
    target_device.save()

    #TODO:アプリへのリダイレクト
    redirect_to "iniadfes://open/renew-permission"
    return
  end

  def sign_out_action
    sign_out
    render plain:"サインアウト完了"
  end
end
