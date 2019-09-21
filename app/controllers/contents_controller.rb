class ContentsController < ApplicationController
  protect_from_forgery :except => [:dump]
  before_action :authentication

  def dump
    contents = Content.all
    data = []

    contents.each do|content|
      data.append({
                      "uuid" => content.uuid,
                      "title" => content.title,
                      "description" => content.description,
                      "organizer" => content.organizer,
                      "place" => content.place
                  })
    end

    render json:{"status" => "success", "objects" => data}
  end
end
