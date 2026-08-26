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
    username = params[:username]

    games = Game.fetch_from_chess_com(username, 50)
    elo = Game.player_elo(username)
    winrate = Game.win_rates(games, username)

    analyzer = DataAnalyzer.new
    result = analyzer.call(games, elo, winrate)

    @analysis = result
  end
end
