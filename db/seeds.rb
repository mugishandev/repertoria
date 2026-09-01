# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Opening.destroy_all
puts "seeding openings..."


openings = [
  { name: "L'Italienne", suite_de_coups: ["1. e4 e5", "2. Nf3 Nc6", "3. Bc4"], color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=5Ny8I1Bj-ek", image: "board_italienne.png" },
  { name: "L'Écossaise", suite_de_coups: ["1. e4 e5", "2. Nf3 Nc6", "3. d4"], color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=nWWe_byE3gM", image: "board_ecossaise.png" },
  { name: "Le Système de Londres", suite_de_coups: ["1. d4 d5", "2. Nf3 Nf6", "3. Bf4"], color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=k86o1Wql56c", image: "board_systeme_londres" },
  { name: "La Scandinave", suite_de_coups: ["1. e4 d5"], color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=1wHJGyWGVLA", image: "board_scandinave" },
  { name: "La Française", suite_de_coups: ["1. e4 e6"], color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=vVz6xqqtP1U", image: "board_francaise" },
  { name: "La Caro-Kann", suite_de_coups: ["1. e4 c6"], color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=hlL9WW5tAUw", image: "board_caro_kann" },
  { name: "Le Gambit Dame refusé", suite_de_coups: ["1. d4 d5", "2. c4 e6"], color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=pE2cSSJdYRY", image: "board_gambit_dame_refuse" },
  { name: "La Défense Slave", suite_de_coups: ["1. d4 d5", "2. c4 c6"], color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=_oHHm7MZAO8", image: "board_slave" },
  { name: "La Défense Hollandaise", suite_de_coups: ["1. d4 f5"], color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=nD6bXC6RQkM", image: "board_hollandaise" }
]

openings.each do |opening|
  Opening.create!(opening)
end
 puts "Seeded #{Opening.count} openings."
