class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  before_action :store_user_location!, if: :storable_location?

  def after_sign_in_path_for(_resource)
    stored_location_for(:user) || root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    request.referer || root_path
  end

  private

  # Clé unique du cache d'analyse pour l'utilisateur courant.
  # Écriture : PagesController#analyse. Lecture : OpeningsController#index et #repertoire.
  def analysis_cache_key
    "analysis/#{current_user.chess_username}"
  end

  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
