Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  get "up" => "rails/health#show", as: :rails_health_check

  root "frontend#home"
  get '/about', to: 'frontend#about', as: 'about'
  get '/contact', to: 'frontend#contact', as: 'contact'
  get '/themes', to: 'frontend#themes', as: 'themes'

  namespace :admin do
    # Dashboard
    get "/", to: 'dashboard#index', as: 'dashboard'

    # Users
    get "/users", to: 'users#index', as: 'users'
    get "/users/new", to: 'users#new', as: 'users_new'
    get "/users/:id", to: 'users#show', as: 'users_show'
    get "/users/:id/edit", to: 'users#edit', as: 'users_edit'
    post "/users", to: 'users#create'
    patch "/users/:id", to: 'users#update'
    put "/users/:id", to: 'users#update'
    delete "/users/:id", to: 'users#destroy'
    get "/users/:id/reset_password", to: 'users#reset_password', as: 'users_reset_password'
    patch "/users/:id/reset_password", to: 'users#update_password'

    # Components
    get "/components", to: 'components#index', as: 'components'
    get "/components/new", to: 'components#new', as: 'components_new'
    get "/components/:id", to: 'components#show', as: 'components_show'
    get "/components/:id/edit", to: 'components#edit', as: 'components_edit'
    post "/components", to: 'components#create'
    patch "/components/:id", to: 'components#update'
    put "/components/:id", to: 'components#update'
    delete "/components/:id", to: 'components#destroy'

    # Themes
    get "/themes", to: 'themes#index', as: 'themes'
    get "/themes/new", to: 'themes#new', as: 'themes_new'
    get "/themes/:id", to: 'themes#show', as: 'themes_show'
    get "/themes/:id/edit", to: 'themes#edit', as: 'themes_edit'
    post "/themes", to: 'themes#create'
    patch "/themes/:id", to: 'themes#update'
    put "/themes/:id", to: 'themes#update'
    delete "/themes/:id", to: 'themes#destroy'

    # Theme Pages
    get "/theme-pages", to: 'theme_pages#index', as: 'theme_pages'
    get "/themes/:id/theme-pages/new", to: 'theme_pages#new', as: 'theme_pages_new'
    get "/themes/:id/theme-pages/:theme_page_id", to: 'theme_pages#show', as: 'theme_pages_show'
    patch "/themes/:id/theme-pages/:theme_page_id/add", to: 'theme_pages#add_component', as: 'theme_pages_add_component'
    delete "/themes/:id/theme-pages/:theme_page_id/remove", to: 'theme_pages#remove_component', as: 'theme_pages_remove_component'
    get "/themes/:id/theme-pages/:theme_page_id/edit", to: 'theme_pages#edit', as: 'theme_pages_edit'
    get "/themes/:id/theme-pages/:theme_page_id/preview", to: 'theme_pages#preview', as: 'theme_pages_preview'
    post "/theme-pages", to: 'theme_pages#create'
    patch "/theme-pages/:id", to: 'theme_pages#update'
    put "/theme-pages/:id", to: 'theme_pages#update'
    delete "/theme-pages/:id", to: 'theme_pages#destroy'


    # Websites
    get "/websites", to: 'websites#index', as: 'websites'
    get "/websites/new", to: 'websites#new', as: 'websites_new'
    get "/websites/:id", to: 'websites#show', as: 'websites_show'
    get "/websites/:id/edit", to: 'websites#edit', as: 'websites_edit'
    post "/websites", to: 'websites#create'
    patch "/websites/:id", to: 'websites#update'
    put "/websites/:id", to: 'websites#update'
    delete "/websites/:id", to: 'websites#destroy'
  end

  namespace :manage do
    # Dashboard
    get "/", to: 'dashboard#index', as: 'dashboard'

    # Account Setup - Add these specific routes
    get "/setup", to: 'account_setups#show', as: 'account_setup'
    get "/setup/step/:step", to: 'account_setups#step', as: 'account_setup_step'
    patch "/setup/step/:step", to: 'account_setups#update_step', as: 'account_setup_update_step'
    post "/setup/create_payment_intent", to: 'account_setups#create_payment_intent', as: 'account_setup_create_payment_intent'
    get "/setup/confirm_payment", to: 'account_setups#confirm_payment', as: 'account_setup_confirm_payment'

    # Websites
    get "/website", to: 'website_builder#index', as: 'website'
    get "/website/new", to: 'websites#new', as: 'websites_new'
    get "/website/settings", to: 'websites#settings', as: 'website_settings'
    post "/website/settings_save", to: 'websites#settings_save', as: 'website_settings_save'
    get "/website/preview/:page_slug", to: 'websites#preview', as: 'website_preview'
    get "website/preview", to: redirect('manage/website/preview/home')
    post "/website", to: 'websites#create'
    patch "/website/:id", to: 'websites#update'
    put "/website/:id", to: 'websites#update'

    # Website Editor
    get '/website/editor/:page_slug', to: 'website_builder#editor', as: 'website_editor'
    get "/website/editor", to: redirect('manage/website/editor/home')
    get '/website/editor/:page_slug/:theme_page_id/:component_id/edit_form', to: 'website_builder#edit_form', as: 'component_edit_form'
    patch '/website/editor/:page_slug/:theme_page_id/:component_id/update_customization', to: 'website_builder#update_customization', as: 'update_component_customization'


  end
end