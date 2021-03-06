ActionController::Routing::Routes.draw do |map|
  
  map.connect '/protocols/update_mult_bats', :controller => 'protocols', :action => 'update_mult_bats'
  map.resources :protocols

  
  #map.connect '/trainings/new_mult_users', :controller => 'trainings', :action => 'new_mult_users'
  #map.connect '/trainings/create_mult_users', :controller => 'trainings', :action => 'create_mult_users'
  map.resources :trainings, :new => { :new_mult_users => :get }, :member => { :create_mult_users => :post }
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "main", :action => "index"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
