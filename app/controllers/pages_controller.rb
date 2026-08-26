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

    games = Game.fetch_from_chess_com(username)

    analyzer = DataAnalyzer.new
    result = analyzer.call(games)

    @analysis = result
  end
end
