require "open-uri"
require "json"
require "net/http"

class Game < ApplicationRecord
  belongs_to :user

  def self.fetch_from_chess_com(username, limit = 50)
    archives_url = URI("https://api.chess.com/pub/player/#{username}/games/archives")
    response = Net::HTTP.get_response(archives_url)
    puts "STATUS : #{response.code}"
    puts "BODY : #{response.body}"
    data = JSON.parse(response.body)
    archives = (data["archives"] || []).reverse
    games = []
    archives.each do |archive_url|
      break if games.length >= limit

      response = Net::HTTP.get(URI(archive_url))
      data = JSON.parse(response)
      games.concat(data["games"])
    end

    games.last(limit)
  end

  def self.player_elo(username)
    url = URI("https://api.chess.com/pub/player/#{username}/stats")

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    data.dig("chess_rapid", "last", "rating")
  end
end
