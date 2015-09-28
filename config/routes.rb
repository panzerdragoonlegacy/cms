Rails.application.routes.draw do
  devise_for :users, path_names: {
    sign_in: "log-in", 
    sign_out: "log-out",
    sign_up: "register"
  }
  resources :users

  resources :contributor_profiles, path: 'contributors' do
    resources :news_entries, path: 'news-entries'
    resources :articles
    resources :downloads
    resources :links
    resources :music_tracks, path: 'music-tracks'
    resources :pictures
    resources :poems
    resources :quizzes
    resources :resources
    resources :stories
    resources :videos
  end
  resources :searches
  get 'site-map', to: 'site_map#show', as: :site_map
  resources :site_map
  resources :sagas
  resources :drafts
  resources :category_groups, path: 'category-groups'
  resources :categories
  resources :articles
  resources :pictures
  resources :downloads
  resources :videos
  resources :quizzes
  resources :news_entries, path: 'news'
  resources :stories
  resources :chapters
  resources :resources
  resources :poems
  resources :music_tracks, path: 'music'
  resources :links
  resources :encyclopaedia_entries, path: 'encyclopaedia'
  resources :emoticons
  resources :pages
  get ':id', to: 'pages#show'
  root to: "news_entries#index"
end
