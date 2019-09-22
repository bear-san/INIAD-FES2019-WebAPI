class ContentsController < ApplicationController
  before_action :authentication

  def index
    contents = Content.all

    if params["room_num"].present? then
      rooms = []
      Room.where(:room_num => params["room_num"].split(",")).each do|room|
        rooms.append(room.ucode)
      end

      contents = contents.where(:place => rooms)
    end

    if params["room_near"].present? then
      related_rooms = []
      Room.where("related_rooms @> ?",[params["room_near"]]).each do|room|
        related_rooms.append(room.ucode)
      end

      contents = contents.where(:place => related_rooms)
    end

    data = []

    contents.each do|content|
      place = Room.where("ucode @> ARRAY[?]::varchar[]",content.place).first()
      organizer = Organization.find_by_ucode(content.organizer)

      data.append({
                      "ucode" => content.ucode,
                      "title" => content.title,
                      "description" => content.description,
                      "organizer" => organizer.organization_name,
                      "place" => place.room_num
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
    place = Room.where("ucode @> ARRAY[?]::varchar[]",content.place).first()
    organizer = Organization.find_by_ucode(content.organizer)

    data = {
        "ucode" => content.ucode,
        "title" => content.title,
        "description" => content.description,
        "organizer" => organizer.organization_name,
        "place" => place.room_num
    }

    render json:{"status" => "success", "object" => data}
  end
end
