Rails.application.routes.draw do
  resources :concerts
  root "concerts#index"

  get 'concert/2014/1' => 'concerts#show'
  get 'concert/2014/2' => 'concerts#show'
  get 'concert/2014/3' => 'concerts#show'
  get 'concert/2014/4' => 'concerts#show'
  get 'concert/2014/5' => 'concerts#show'
  get 'concert/2014/6' => 'concerts#show'
  get 'concert/2014/7' => 'concerts#show'
  get 'concert/2014/8' => 'concerts#show'
  get 'concert/2014/9' => 'concerts#show'
  get 'concert/2014/10' => 'concerts#show'
  get 'concert/2014/11' => 'concerts#show'
  get 'concert/2014/12' => 'concerts#show'

  get 'concert/2015/1' => 'concerts#show'
  get 'concert/2015/2' => 'concerts#show'
  get 'concert/2015/3' => 'concerts#show'
  get 'concert/2015/4' => 'concerts#show'
  get 'concert/2015/5' => 'concerts#show'
  get 'concert/2015/6' => 'concerts#show'
  get 'concert/2015/7' => 'concerts#show'
  get 'concert/2015/8' => 'concerts#show'
  get 'concert/2015/9' => 'concerts#show'
  get 'concert/2015/10' => 'concerts#show'
  get 'concert/2015/11' => 'concerts#show'
  get 'concert/2015/12' => 'concerts#show'

  match "day", :controller => :concerts, :action => :show, :via => :get

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
