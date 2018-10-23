Rails.application.routes.draw do


    resources :students
<<<<<<< HEAD
    resources :professors
    resources :courses
    resources :enrollments

    match '/test' => 'professors#new', via: [:get]
=======
    resources :photos
    
>>>>>>> caabc45fb94e53672f2984a9be75267de6e55deb
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
