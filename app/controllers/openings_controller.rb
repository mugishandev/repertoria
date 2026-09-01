class OpeningsController < ApplicationController
  before_action :set_opening, only: [
    :show,
    :description,
    :explanation,
    :resources,
    :tab_content
  ]

  def index
    @last_update = DataAnalyzer.maximum(:updated_at)
  end

  def repertoire
    @openings = Opening.all
    @username = session[:username]

    games = Game.fetch_from_chess_com(@username)
    elo = Game.player_elo(@username)
    winrate = Game.win_rates(games, @username)

    analysis = DataAnalyzer.new.call(games, elo, winrate)

    puts analysis.inspect

    @opening_counts = {}
    @opening_win_rates = {}

    categories = ["white", "black_vs_e4", "black_vs_d4"]

    @openings.each do |opening|
      category = categories.find do |cat|
      analysis.dig(cat, "opening") == opening.name
      end

      if category
      opening_urls = analysis.dig(category, "opening_games") || []

      stats = Game.opening_stats(
        games,
        @username,
        opening_urls
      )

      @opening_counts[opening.id] = stats[:count]
      @opening_win_rates[opening.id] = stats[:win_rate]
      else
      @opening_counts[opening.id] = 0
      @opening_win_rates[opening.id] = 0
      end
    end
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

  def set_opening
    @opening = Opening.find(params[:id])
  end
end
