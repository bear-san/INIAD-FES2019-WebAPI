Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #

  scope :api do
    scope :v1 do

      scope :user do
        post '/new', to:'user#new'
        post '/', to:'user#update_notification_token'
      end

      scope :contents do
        get '/', to:'contents#index'
        get '/:ucode',to:"contents#show"
      end
    end
  end

  match "*path" => "application#not_found", via: :all
end
