#== Route Map
# Generated on 23 Oct 2012 15:43
#
#            users_new GET /users/new(.:format)            users#new
#  static_pages_signin GET /static_pages/signin(.:format)  static_pages#signin
#  static_pages_signup GET /static_pages/signup(.:format)  static_pages#signup
#   static_pages_about GET /static_pages/about(.:format)   static_pages#about
# static_pages_contact GET /static_pages/contact(.:format) static_pages#contact
#                 root     /                               StaticPages#home
#               signin     /signin(.:format)               StaticPages#signin
#               signup     /signup(.:format)               Users#new
#                about     /about(.:format)                StaticPages#about
#              contact     /contact(.:format)              StaticPages#contact

Webclient::Application.routes.draw do
  resources :users

  get 'static_pages/home'
  get "users/new"
  # get 'static_pages/help'
  # match '/help' => "StaticPages#help"
  match '/signup' => "Users#new"
  get 'static_pages/signin'
  get 'static_pages/about'
  get 'static_pages/contact'

  root :to => "StaticPages#home"
  # match '/help' => "StaticPages#help"
  match '/signin' => "StaticPages#signin"
  match '/signup' => "Users#new"
  match '/about' => "StaticPages#about"
  match '/contact' => "StaticPages#contact"
end
