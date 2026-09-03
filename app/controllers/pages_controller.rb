class PagesController < ApplicationController
  before_action :authenticate_user!, only: :analyse

  ANALYSIS_CATEGORIES = %w[white black_vs_e4 black_vs_d4].freeze

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

  # Seule action qui lance une analyse Chess.com + LLM.
  # Elle calcule tout, stocke le résultat dans le cache, puis redirige vers le Dashboard
  # (openings#index). Le Dashboard et le Répertoire relisent ce même cache : un refresh
  # de l'une ou l'autre page ne relance aucune analyse.
  def analyse
    current_user.update!(chess_username: params[:username].to_s.strip.downcase) if params[:username].present?
    username = current_user.chess_username

    if username.blank?
      redirect_to root_path, alert: "Renseigne ton pseudo Chess.com pour lancer l'analyse."
      return
    end

    games = Game.fetch_from_chess_com(username, 100)

    if games.empty?
      redirect_to root_path, alert: "Le joueur « #{username} » n'existe pas sur Chess.com..."
      return
    end

    if games.count < 10
      redirect_to root_path, alert: "Vous devez avoir joué au moins 10 parties..."
      return
    end

    elo      = Game.player_elo(username)
    winrate  = Game.win_rates(games, username).stringify_keys
    analysis = DataAnalyzer.new.call(games, elo, winrate, username)
    opening_counts, opening_win_rates = opening_stats_for(games, username, analysis)

    Rails.cache.write(analysis_cache_key, {
      analysis: analysis,
      games: games,
      games_count: games.count,
      winrate: winrate,
      elo: elo,
      last_update: Time.current,
      opening_counts: opening_counts,
      opening_win_rates: opening_win_rates
    }, expires_in: 1.hour)

    redirect_to openings_path, notice: "Analyse terminée."
  end

  private

  # Rejoue les stats par ouverture à partir des games déjà récupérées et de l'analyse LLM.
  # Fait ici (seul endroit qui possède `games`) pour que /repertoire n'ait rien à recalculer.
  def opening_stats_for(games, username, analysis)
    counts = {}
    win_rates = {}

    Opening.all.each do |opening|
      category = ANALYSIS_CATEGORIES.find { |cat| analysis.dig(cat, "opening") == opening.name }

      if category
        opening_urls = analysis.dig(category, "opening_games") || []
        stats = Game.opening_stats(games, username, opening_urls)
        counts[opening.id] = stats[:count]
        win_rates[opening.id] = stats[:win_rate]
      else
        counts[opening.id] = 0
        win_rates[opening.id] = 0
      end
    end

    [counts, win_rates]
  end
end
