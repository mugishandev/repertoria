class OpeningsController < ApplicationController
  before_action :authenticate_user!, only: %i[index repertoire]
  before_action :load_last_analysis, only: %i[index repertoire white black_vs_d4 black_vs_e4]
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

  def white
    render partial: "white"
  end

  def black_vs_d4
    render partial: "black_vs_d4"
  end

  def black_vs_e4
    render partial: "black_vs_e4"
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
    @games             = cached[:games] || []

    @analysis_key =
      if %w[white black_vs_e4 black_vs_d4].include?(action_name)
        action_name
      else
        "white"
      end
    opening_urls = @analysis.dig(@analysis_key, "opening_games") || []

    @opening_stats = Game.opening_stats(
      @games,
      @username,
      opening_urls
    )
    puts "=== OPENING STATS ==="
    puts @opening_stats.inspect
    @last_games = Game.opening_games(@games, opening_urls).first(3)

    @opening = Opening.find_by(
      name: @analysis.dig(@analysis_key, "opening")
    )
  end

  def set_opening
    @opening = Opening.find(params[:id])
  end
end
