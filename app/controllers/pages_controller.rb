class PagesController < ApplicationController
  before_action :authenticate_user!, only: %i[analyse analyse_status]

  def home
  end

  def about
  end

  def legals
  end

  def cgu
  end

  def confidentials
  end

  # Point d'entrée de l'analyse Chess.com + LLM. L'analyse elle-même tourne désormais
  # dans AnalyseRepertoireJob : l'action se contente d'enfiler le job et de rendre
  # l'écran de chargement. Le job écrit le résultat dans le même cache
  # (analysis/<username>) relu par OpeningsController.
  def analyse
    current_user.update!(chess_username: params[:username].to_s.strip.downcase) if params[:username].present?
    username = current_user.chess_username

    if username.blank?
      redirect_to root_path, alert: "Renseigne ton pseudo Chess.com pour lancer l'analyse."
      return
    end

    status = Rails.cache.read(analysis_status_cache_key)
    unless status && status[:state] == "processing"
      Rails.cache.write(analysis_status_cache_key, { state: "processing" }, expires_in: 1.hour)
      AnalyseRepertoireJob.perform_later(current_user.id)
    end

    render :analyse
  end

  # Statut de l'analyse en cours, interrogé par le loader (analysis_poll_controller).
  def analyse_status
    render json: Rails.cache.read(analysis_status_cache_key) || { state: "idle" }
  end

  private

  # Drapeau d'avancement de l'analyse (processing / done / error) pour le loader.
  # Distinct de analysis_cache_key : le résultat d'analyse reste stocké une seule fois.
  def analysis_status_cache_key
    "analysis_status/#{current_user.chess_username}"
  end
end
