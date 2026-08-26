require "open-uri"
require "json"
require "net/http"

class Game < ApplicationRecord
  belongs_to :user

  # Récupère les dernières parties RAPID du joueur
  def self.fetch_from_chess_com(username, limit = 50)
    archives_url = URI(
      "https://api.chess.com/pub/player/#{username}/games/archives"
    )

    response = Net::HTTP.get_response(archives_url)
    data = JSON.parse(response.body)

    # On commence par les archives les plus récentes
    archives = (data["archives"] || []).reverse

    games = []

    archives.each do |archive_url|
      response = Net::HTTP.get(URI(archive_url))
      data = JSON.parse(response)

      # On garde uniquement les parties Rapid
      rapid_games = data["games"].select do |game|
        game["time_class"] == "rapid"
      end

      games.concat(rapid_games)

      # On s'arrête dès qu'on a suffisamment de parties Rapid
      break if games.length >= limit
    end

    # On garde les 50 dernières maximum
    games.last(limit)
  end



  # Récupère l'ELO Rapid actuel du joueur
  def self.player_elo(username)
    url = URI(
      "https://api.chess.com/pub/player/#{username}/stats"
    )

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    data.dig("chess_rapid", "last", "rating")
  end



  # Calcule le taux de victoire avec les Blancs et les Noirs
  def self.win_rates(games, username)
    username = username.downcase

    # Parties où le joueur joue les Blancs
    white_games = games.select do |game|
      game.dig("white", "username")&.downcase == username
    end

    # Parties où le joueur joue les Noirs
    black_games = games.select do |game|
      game.dig("black", "username")&.downcase == username
    end

    # Victoires avec les Blancs
    white_wins = white_games.count do |game|
      game.dig("white", "result") == "win"
    end

    # Victoires avec les Noirs
    black_wins = black_games.count do |game|
      game.dig("black", "result") == "win"
    end

    {
      white: white_games.any? ?
        (white_wins.to_f / white_games.count * 100).round(2) : 0,

      black: black_games.any? ?
        (black_wins.to_f / black_games.count * 100).round(2) : 0
    }
  end
end
