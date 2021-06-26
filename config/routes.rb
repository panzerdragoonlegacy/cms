Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {
    sign_in: "log-in",
    sign_out: "log-out",
    edit: "edit-profile"
  }

  namespace :admin do
    get '/', to: 'home#index'

    resources :albums
    resources :category_groups, path: 'category-groups'
    resources :categories
    resources :sagas
    resources :tags
    resources :redirects

    resources :contributor_profiles, path: 'contributor-profiles'
    resources :users

    resources :news_entries, path: 'news-entries'
    resources :pages
    resources :pictures
    resources :music_tracks, path: 'music-tracks'
    resources :videos
    resources :downloads
    resources :quizzes
  end

  namespace :redesign do
    get '/', to: 'home#index'
  end

  resources :searches
  resources :news_entries, path: 'news'
  get 'site-map', to: 'site_map#show', as: :site_map
  resources :site_map
  resources :categories
  get 'encyclopaedia', to: 'encyclopaedia#index', as: 'encyclopaedia_index'
  get 'encyclopaedia/:id', to: 'encyclopaedia#show', as: 'encyclopaedia'
  resources :tags
  resources :contributions

  resources :contributor_profiles, path: 'contributors' do
    resources :news_entries, path: 'news-entries'
    resources :literature
    resources :pictures
    resources :music_tracks, path: 'music-tracks'
    resources :downloads
    resources :videos
    resources :quizzes
  end

  resources :news_entries, path: 'news'
  resources :literature, only: %i(index show) do
    resources :chapters, only: :show
  end
  resources :pictures
  resources :music_tracks, path: 'music'
  resources :videos
  resources :downloads
  resources :quizzes

  get ':id', to: 'top_level_page#show', as: 'top_level_page'
  root to: 'home#show'
end
