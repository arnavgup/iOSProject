Rails.application.routes.draw do


    resources :students
    resources :professors
    resources :courses
    resources :enrollments
    resources :photos
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
