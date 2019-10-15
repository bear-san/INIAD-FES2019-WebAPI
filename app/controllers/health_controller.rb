class HealthController < ApplicationController
  def app
    render json:{"status" => "success", "description" => "INIAD-FES2019 API SERVER IS RUNNING", "number_of_cluster" => ENV["SERVER_NUMBER"]}
  end

  def db
    begin
      db_response = ActiveRecord::Migrator.current_version
    rescue ActiveRecordError
      render plain:"Error",status:503
      return
    end

    render json:{"status" => "success", "description" => "DATABASE CONNECTION", "number_of_cluster" => ENV["SERVER_NUMBER"], "db_response" => db_response}
  end

end
