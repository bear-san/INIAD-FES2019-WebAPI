Rails.application.routes.draw do
  devise_for :fes_users, :only => []
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #

  scope :api do
    scope :v1 do
      scope :user do
        get '/', to:'user#dump_data'
        post '/new', to:'user#new'
        post '/', to:'user#update_notification_token'
      end

      scope :contents do
        get '/', to:'contents#index'
        get '/:ucode',to:"contents#show"
      end

      scope :visitor do
        get '/',to:"visitor#dump_data"
        post 'attributes',to:"visitor#in_app_registration"
        post 'entry/:ucode',to:"visitor#entry_event"
      end

      scope :admin do
        post 'reception', to:"visitor#reception"
      end

      scope :health do
        get 'app',to:"health#app"
        get 'db',to:"health#db"
      end

      get :notifications, to:"push_notification#dump"
    end
  end

  scope :admin do
    get "/",to:"admin#index"
    get "contents",to:"admin#show_contents"
    get "contents/new",to:"admin#create_contents_page"
    post "contents/new",to:"admin#create_contents"
    get "contents/:ucode/edit",to:"admin#edit_contents"
    post "contents/:ucode/edit",to:"admin#update_contents"

    get "organizations",to:"admin#show_organizer"
    get "organizations/new",to:"admin#create_organizer_page"
    post 'organizations/new',to:"admin#create_organizer"
    get "organizations/:ucode/edit",to:"admin#edit_organizer_page"
    post 'organizations/:ucode/edit',to:"admin#edit_organizer"

    get 'users',to:"admin#show_users_page"
    get 'users/new',to:"admin#create_users_page"
    post 'users/new',to:"admin#create_users"
    get 'users/:iniad_id/edit',to:"admin#edit_users_page"
    post 'users/:iniad_id/edit',to:"admin#edit_users"

    resources :push_notification, :except => [:update,:destroy]
  end

  scope :auth do
    get "g",to:"admin#auth"
    get "g/callback",to:"admin#auth_callback"
    get "circle",to:"admin#app_auth"
  end

  scope :visitor do
    get 'attribute/register',to:"visitor#register_attribute_form"
    post 'attribute/register',to:"visitor#register_attribute"
    get 'final-enquete',to:"visitor#final_enquete"
  end

  get 'manual', to:"meta_information#manual"
  get 'privacy', to:"meta_information#privacy"

  match "*path" => "application#not_found", via: :all
end
