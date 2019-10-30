require 'devise'
require 'net/http'
require 'json'
class PushNotificationController < ApplicationController
  before_action :check_sign_in_status, :except => [:dump,:public]
  before_action :authentication, :only => [:dump]

  def index
    @notifications = PushNotification.all
  end

  def show
    @notification = PushNotification.find_by_id(params[:id])
  end

  def create
    #validation
    if !params[:title].present? or !params[:message].present? or !params[:target].present? then
      flash[:error] = "warning:題名・本文・配信対象はいずれも必須です"
      redirect_to request.referer
      return
    end

    new_notification = PushNotification.new
    new_notification.title = params[:title]
    new_notification.message = params[:message]
    new_notification.target = params[:target]
    new_notification.issued_time = Time.now

    new_notification.save()

    notification_devices = {"iOS" => [], "Android" => []}

    if params[:target] == "all"
      #全ユーザー
      User.where(:device_type => "iOS").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["iOS"].append(user.notification_token)
      end

      User.where(:device_type => "Android").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["Android"].append(user.notification_token)
      end
    elsif params[:target] == "visitor" then
      #一般来場者
      users = User.where("role @> ARRAY[?]::varchar[]",["visitor"])
      users.where(:device_type => "iOS").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["iOS"].append(user.notification_token)
      end

      users.where(:device_type => "Android").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["Android"].append(user.notification_token)
      end
    elsif params[:target] == "student" then
      #参加団体などINIAD-FES関係者
      users = User.where("role @> ARRAY[?]::varchar[]",["circle_participant"])
      users.where(:device_type => "iOS").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["iOS"].append(user.notification_token)
      end

      users.where(:device_type => "Android").each do|user|
        if !user.notification_token.present? then
          next
        end
        notification_devices["Android"].append(user.notification_token)
      end
    end

    #Gaurunへの配信処理
    url = "#{ENV["GAURUN_ADDR"]}/push"
    uri = URI.parse(url)

    request = Net::HTTP::Post.new(uri.path)
    request.body = {
        "notifications" => [
            {
                "token" => notification_devices["iOS"].uniq,
                "platform" => 1,
                "title" => new_notification.title,
                "message" => new_notification.message,
            },
            {
                "token" => notification_devices["Android"].uniq,
                "platform" => 2,
                "message" => "#{new_notification.title}\n#{new_notification.message}"
            }
        ]
    }.to_json
    response = Net::HTTP.new(uri.host,uri.port).start do|http|
      http.request(request)
    end

    flash[:error] = "success:登録・配信が完了しました"
    redirect_to push_notification_index_path
  end

  def dump

    if !@user.role.include?("circle_participant") and !@user.role.include?("fes_committee") then
      render json:{"status" => "success", "objects" => PushNotification.where(:target => "all").or(PushNotification.where(:target => "visitor"))}
    else
      render json:{"status" => "success", "objects" => PushNotification.all}
    end
  end

  def public
    render json:{"status" => "success", "objects" => PushNotification.where(:target => "all").or(PushNotification.where(:target => "visitor"))}
  end
end
