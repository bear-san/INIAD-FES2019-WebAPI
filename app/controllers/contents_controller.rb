class ContentsController < ApplicationController
  before_action :authentication

  def index
    contents = Content.all

    if params["room_num"].present? then
      contents = contents.where(:place => params["room_num"].split(","))
    end

    if params["room_near"].present? then
      related_rooms = []
      Room.where(:room_num => params["room_near"].split(",")).each do|room|
        related_rooms.append(room.room_num)
      end

      contents = contents.where(:place => related_rooms)
    end

    data = []

    contents.each do|content|
      data.append({
                      "ucode" => content.ucode,
                      "title" => content.title,
                      "description" => content.description,
                      "organizer" => content.organizer,
                      "place" => content.place
                  })
    end

    render json:{"status" => "success", "objects" => data}
  end

  def show
    if !params["ucode"].present? then
      render json:{"status" => "error", "description" => "required parameter missing"},status:400
      return
    end

    content = Content.find_by_ucode(params["ucode"])
    data = {
        "ucode" => content.ucode,
        "title" => content.title,
        "description" => content.description,
        "organizer" => content.organizer,
        "place" => content.place
    }

    render json:{"status" => "success", "object" => data}
  end
end
