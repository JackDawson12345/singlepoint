Rails.application.routes.draw do
  Rails.application.routes.draw do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  end
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
    post "/theme-pages", to: 'theme_pages#create'
    patch "/theme-pages/:id", to: 'theme_pages#update'
    put "/theme-pages/:id", to: 'theme_pages#update'
    delete "/theme-pages/:id", to: 'theme_pages#destroy'

  end
end
