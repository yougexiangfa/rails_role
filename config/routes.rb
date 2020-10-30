Rails.application.routes.draw do

  scope :panel, module: 'role/panel', as: :panel, defaults: { namespace: 'panel', business: 'role' } do
    resources :roles do
      member do
        get :overview
      end
      resources :who_roles, only: [:index, :new, :create, :destroy]
    end
    resources :governs, only: [:index] do
      collection do
        post :sync
        get :namespace
        get :governs
      end
      member do
        patch :move_lower
        patch :move_higher
      end
      resources :rules do
        member do
          patch :move_lower
          patch :move_higher
          get :roles
        end
      end
    end
    resources :name_spaces do
      collection do
        post :sync
      end
      member do
        patch :move_lower
        patch :move_higher
      end
    end
    resources :busynesses do
      collection do
        post :sync
      end
    end
  end

  scope :admin, module: 'role/admin', as: :admin, defaults: { namespace: 'admin', business: 'role' } do
    scope path: ':who_type/:who_id' do
      resource :who_roles, only: [:show, :edit, :update]
    end
  end

end

