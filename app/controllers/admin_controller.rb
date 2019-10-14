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

    ucode = Ucode.where(:allocated => false).first()

    content.place = params["place"]
    content.description = params["description"]
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
    begin
      new_organization.members = params["member"].split(",")
    end

    new_organization.save()
    ucode.allocated = true
    ucode.save()

    flash[:error] = "success:登録が完了しました"
    redirect_to "/admin/organizations"
  end

  def edit_organizer_page
    @organization = Organization.find_by_ucode(params[:ucode])
    if !@organization.present? then
      flash[:error] = "danger:該当する組織が存在しません"
    end

    render template: "admin/edit_organizer"
  end
end
