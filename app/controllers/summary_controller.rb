class SummaryController < ApplicationController
  def show
    target_content = Content.find_by_ucode(params[:ucode])
    if !target_content.present? then
      flash.now[:error] = "danger:指定されたucodeに該当する企画情報がありません"
      return
    end

    render json:{"status" => "success", "data" => target_content}
  end
end
