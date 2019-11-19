require 'devise'
class SummaryController < ApplicationController
  include Devise::Controllers::SignInOut
  before_action :check_sign_in_status
  def show
    target_content = Content.find_by_ucode(params[:ucode])
    if !target_content.present? then
      flash.now[:error] = "danger:指定されたucodeに該当する企画情報がありません"
      return
    end

    organization = Organization.find_by_ucode(target_content.organizer)

    if !(current_fes_user.role & ["Developer","FesAdmin","FesCommittee"]).present? and !organization.members.include?(current_fes_user.iniad_id) then
      flash.now[:error] = "danger:データへのアクセス権がありません"
      return
    end

    visitors = []
    target_content["visitors"].each do|visitor|
      visitors.append("user" => VisitorAttribute.find_by_user_id(visitor["user_id"]), "timestamp" => Time.parse(visitor["timestamp"]).in_time_zone("Tokyo"))
    end

    target_content["visitors"] = visitors.uniq{|visitor| visitor["user"].user_id}.sort{|visitor1, visitor2| visitor1["timestamp"] <=> visitor2["timestamp"]}

    @contents = target_content
    base_unix_time = [1572742800,1572829200]

    @visitor_by_hours = [
    ]

    5.times do
      base_unix_time[0] += 7200
      @visitor_by_hours.append(target_content["visitors"].select{|visitor| Time.parse(visitor["timestamp"]).to_i >= base_unix_time[0] and Time.parse(visitor["timestamp"]).to_i < base_unix_time[0] + 7200}.sum{|visitor| visitor["user"]["visitor_attribute"]["number_of_people"].to_i})
    end

    5.times do
      base_unix_time[1] += 7200
      @visitor_by_hours.append(target_content["visitors"].select{|visitor| Time.parse(visitor["timestamp"]).to_i >= base_unix_time[1] and Time.parse(visitor["timestamp"]).to_i < base_unix_time[1] + 7200}.sum{|visitor| visitor["user"]["visitor_attribute"]["number_of_people"].to_i})
    end
    #render json:{"status" => "success", "data" => target_content}
    return


  end
end
