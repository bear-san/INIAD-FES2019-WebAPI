class AdminController < ApplicationController
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
    content.place = params["place"]
    content.description = params["description"]
    content.ucode = Ucode.where(:allocated => false).first().ucode #未割り当てucodeのうち、適当なものを割り当てる

    content.save()
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

    content.save()
    flash[:error] = "success:更新が完了しました"

    redirect_to "/admin/contents"
  end

  
end
