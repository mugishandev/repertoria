class PagesController < ApplicationController
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

  def analyse
    @username = params[:username].strip.downcase

    # Si on a déjà analysé ce username pendant cette session,
    # on récupère directement les données sans refaire l'analyse.
    if session[:username] == @username && session[:analysis].present?
      @analysis = session[:analysis]
      @games_count = session[:games_count]
      @winrate = session[:winrate]
      @elo = session[:elo]
      @last_update = Time.parse(session[:last_update]) if session[:last_update].present?

      render "openings/index"
      return
    end

    # Première analyse de ce username
    @games = Game.fetch_from_chess_com(@username, 50)

    if @games.empty?
      redirect_to root_path,
        alert: "Le joueur « #{@username} » n'existe pas sur Chess.com."
      return
    end

    if @games.count < 10
      redirect_to root_path,
        alert: "Vous devez jouer au moins 10 parties pour lancer l'analyse"
      return
    end

    @elo = Game.player_elo(@username)
    @winrate = Game.win_rates(@games, @username).stringify_keys

    analyzer = DataAnalyzer.new
    @analysis = analyzer.call(@games, @elo, @winrate)

    # On sauvegarde tout ce dont la vue aura besoin
    session[:username] = @username
    session[:analysis] = @analysis
    session[:games_count] = @games.count
    session[:winrate] = @winrate
    session[:elo] = @elo
    session[:last_update] = Time.current.iso8601

    @last_update = Time.parse(session[:last_update])

    render "openings/index"
  end
end
