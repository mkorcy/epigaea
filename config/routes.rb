Rails.application.routes.draw do
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # Routes for managing drafts
  get '/draft/apply_draft/:id', to: 'tufts/draft#apply_draft'
  post '/draft/save_draft/:id', to: 'tufts/draft#save_draft'
  post '/draft/delete_draft/:id', to: 'tufts/draft#delete_draft'
  get '/draft/draft_saved/:id', to: 'tufts/draft#draft_saved'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
