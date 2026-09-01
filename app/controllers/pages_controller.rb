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
    session[:username] = @username
    cached = Rails.cache.read("analysis/#{@username}")
    if cached
      @analysis     = cached[:analysis]
      @games_count  = cached[:games_count]
      @winrate      = cached[:winrate]
      @elo          = cached[:elo]
      @last_update  = cached[:last_update]

      render "openings/index"
      return
    end

    @games = Game.fetch_from_chess_com(@username, 50)

    if @games.empty?
      redirect_to root_path, alert: "Le joueur « #{@username} » n'existe pas sur Chess.com..."
      return
    end

    if @games.count < 10
      redirect_to root_path, alert: "Vous devez avoir joué au moins 10 parties..."
      return
    end

    @elo         = Game.player_elo(@username)
    @winrate     = Game.win_rates(@games, @username).stringify_keys
    @games_count = @games.count
    @analysis    = DataAnalyzer.new.call(@games, @elo, @winrate)
    @last_update = Time.current

    Rails.cache.write("analysis/#{@username}", {
      analysis: @analysis,
      games_count: @games_count,
      winrate: @winrate,
      elo: @elo,
      last_update: @last_update
    }, expires_in: 1.hour)

    render "openings/index"
  end
end
