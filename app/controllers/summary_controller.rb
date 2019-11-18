class SummaryController < ApplicationController
  before_action :check_sign_in_status
  def show
    target_content = Content.find_by_ucode(params[:ucode])
    if !target_content.present? then
      flash.now[:error] = "danger:指定されたucodeに該当する企画情報がありません"
      return
    end

    visitors = []
    target_content["visitors"].each do|visitor|
      visitors.append("user" => VisitorAttribute.find_by_user_id(visitor["user_id"]), "timestamp" => Time.parse(visitor["timestamp"]).in_time_zone("Tokyo"))
    end

    target_content["visitors"] = visitors.uniq{|visitor| visitor["user"].user_id}.sort{|visitor| visitor["timestamp"]}

    render json:{"status" => "success", "data" => target_content}
    return


  end
end
