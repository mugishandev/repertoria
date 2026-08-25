require "open-uri"
require "json"

class Game < ApplicationRecord
  belongs_to :user

  # url = "https://api.chess.com/pub/player/#{@username}/games"

  # response = URI.open(url).read
  # game_data = JSON.parse(response)

end
