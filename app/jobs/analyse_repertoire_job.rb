class AnalyseRepertoireJob < ApplicationJob
  queue_as :default

  ANALYSIS_CATEGORIES = %w[white black_vs_e4 black_vs_d4].freeze

  # Exécute en arrière-plan l'analyse Chess.com + LLM qui était auparavant faite
  # de façon synchrone dans PagesController#analyse. La logique métier est reprise
  # telle quelle : mêmes appels, même structure écrite dans le même cache.
  def perform(user_id)
    user = User.find(user_id)
    username = user.chess_username
    return if username.blank?

    games = Game.fetch_from_chess_com(username, 100)

    if games.empty?
      write_status(username, "error", "Le joueur « #{username} » n'existe pas sur Chess.com...")
      return
    end

    if games.count < 10
      write_status(username, "error", "Vous devez avoir joué au moins 10 parties...")
      return
    end

    elo      = Game.player_elo(username)
    winrate  = Game.win_rates(games, username).stringify_keys
    analysis = DataAnalyzer.new.call(games, elo, winrate, username)
    opening_counts, opening_win_rates = opening_stats_for(games, username, analysis)

    Rails.cache.write("analysis/#{username}", {
      analysis: analysis,
      games: games,
      games_count: games.count,
      winrate: winrate,
      elo: elo,
      last_update: Time.current,
      opening_counts: opening_counts,
      opening_win_rates: opening_win_rates
    }, expires_in: 1.hour)

    write_status(username, "done")
  rescue StandardError
    write_status(username, "error", "Une erreur est survenue pendant l'analyse. Réessaie.") if username.present?
    raise
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

  # Drapeau d'avancement lu par PagesController#analyse_status / le loader.
  def write_status(username, state, message = nil)
    target = state == "done" ? "/openings" : "/"
    Rails.cache.write("analysis_status/#{username}",
                      { state: state, message: message, redirect_to: target },
                      expires_in: 1.hour)
  end
end
