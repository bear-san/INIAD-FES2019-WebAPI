class ContentsController < ApplicationController
  protect_from_forgery :except => [:dump]
  before_action :authentication

  def dump
    contents = Content.all

    if params["room_num"].present? then
      contents = contents.where(:place => params["room_num"])
    end

    if params["room_near"].present? then
      related_rooms = []
      Room.where(:room_num => params["room_near"]).each do|room|
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
end
