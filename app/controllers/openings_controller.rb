class OpeningsController < ApplicationController
  before_action :authenticate_user!, only: %i[index repertoire]
  before_action :load_last_analysis, only: %i[index repertoire]
  before_action :set_opening, only: [
    :show,
    :description,
    :explanation,
    :resources,
    :tab_content
  ]

  # Dashboard : affichage global de la dernière analyse (profil, ELO, winrate,
  # 3 ouvertures recommandées). Display only — aucun appel Chess.com ni LLM.
  def index
  end

  # Répertoire : statistiques détaillées par ouverture, calculées lors de l'analyse
  # et relues depuis le cache. Display only — aucun appel Chess.com ni LLM.
  def repertoire
    @openings = Opening.all
    # if @opening.color == "white"
    #   @analysis_key = "white"
    # else
    #   @analysis_key = "black_vs_#{@opening.against}"
    # end
  end

  def show
    @opening = Opening.find(params[:id])
  end

  def description
    render partial: "description"
  end

  def explanation
    render partial: "explanation"
  end

  def resources
    render partial: "resources"
  end

  def tab_content
    render partial: "tab_content"
  end

  private

  # Charge la dernière analyse (Dashboard + Répertoire lisent la même).
  # Redirige proprement si le pseudo Chess.com ou l'analyse manquent — ne relance rien.
  def load_last_analysis
    if current_user.chess_username.blank?
      redirect_to root_path, alert: "Renseigne ton pseudo Chess.com pour lancer une analyse."
      return
    end

    cached = Rails.cache.read(analysis_cache_key)

    if cached.blank?
      redirect_to root_path, alert: "Lance d'abord une analyse."
      return
    end

    @username          = current_user.chess_username
    @analysis          = cached[:analysis]
    @elo               = cached[:elo]
    @winrate           = cached[:winrate]
    @games_count       = cached[:games_count]
    @last_update       = cached[:last_update]
    @opening_counts    = cached[:opening_counts] || {}
    @opening_win_rates = cached[:opening_win_rates] || {}
  end

  def set_opening
    @opening = Opening.find(params[:id])
  end
end
