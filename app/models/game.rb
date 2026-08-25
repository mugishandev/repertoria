require "open-uri"
require "json"
require "net/http"

class Game < ApplicationRecord
  belongs_to :user

  def self.fetch_from_chess_com(username)
    archives_url = URI("https://api.chess.com/pub/player/#{username}/games/archives")

    response = Net::HTTP.get(archives_url)
    data = JSON.parse(response)

    last_archive = data["archives"].last

    return [] if last_archive.nil?

    games_url = URI(last_archive)

    response = Net::HTTP.get(games_url)
    data = JSON.parse(response)

    data["games"]
  end
end
