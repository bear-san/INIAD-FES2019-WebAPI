require 'devise'
require 'net/http'
require 'json'
class PushNotificationController < ApplicationController
  before_action :check_sign_in_status, :except => [:dump]
  before_action :authentication, :only => [:dump]

  def index
    @notifications = PushNotification.all
  end

  def show
    @notification = PushNotification.find_by_id(params[:id])
  end

  def create
    new_notification = PushNotification.new
    new_notification.title = params[:title]
    new_notification.message = params[:message]
    new_notification.issued_time = Time.now

    new_notification.save()


    #TODO:Gaurunへの配信処理

    flash[:error] = "success:登録・配信が完了しました"
    redirect_to push_notification_index_path
  end

  def dump
    render json:{"status" => "success", "objects" => PushNotification.all}
  end
end
