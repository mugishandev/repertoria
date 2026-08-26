class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :analyse ]

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
    username = params[:username].strip.downcase
    games = Game.fetch_from_chess_com(username, 50)
    if games.empty?
      redirect_to root_path,
      alert: "Le joueur « #{username} » n'existe pas sur Chess.com."
      return
    end
    if games.count < 10
      redirect_to root_path,
        alert: "Vous devez jouer au moins 10 parties pour lancer l'analyse"
      return
    end
    elo = Game.player_elo(username)
    winrate = Game.win_rates(games, username)

    analyzer = DataAnalyzer.new
    result = analyzer.call(games, elo, winrate)

    @analysis = result
  end
end
