class AdminController < ApplicationController
  def show_contents
    @contents = Content.all.order(:id)
  end

  def edit_contents
    @contents = Content.find_by_ucode(params[:ucode])

    if !@contents.present? then
      flash.now[:error] = "danger:該当する企画がありません"
    end
  end
end
