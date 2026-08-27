# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

openings = [
  { name: "L'Italienne", suite_de_coups: "1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.d3 Nf6 5.O-O O-O 6.Re1" },
  { name: "L'Écossaise", suite_de_coups: "1.e4 e5 2.Nf3 Nc6 3.d4 exd4 4.Nxd4 Nf6 5.Nxc6 bxc6 6.Bd3" },
  { name: "Le Système de Londres", suite_de_coups: "1.d4 d5 2.Nf3 Nf6 3.Bf4 e6 4.e3 Bd6 5.Bg3 O-O 6.Bd3" },
  { name: "La Scandinave", suite_de_coups: "1.e4 d5 2.exd5 Qxd5 3.Nc3 Qd8 4.d4 Nf6 5.Nf3 c6 6.Bc4" },
  { name: "La Française", suite_de_coups: "1.e4 e6 2.d4 d5 3.Nc3 Nf6 4.e5 Nfd7 5.f4 c5 6.Nf3" },
  { name: "La Caro-Kann", suite_de_coups: "1.e4 c6 2.d4 d5 3.Nc3 dxe4 4.Nxe4 Bf5 5.Ng3 Bg6 6.Nf3" },
  { name: "Le Gambit Dame refusée", suite_de_coups: "1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 Be7 5.Bg5 O-O 6.e3" },
  { name: "La Défense Slave", suite_de_coups: "1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4 5.a4 Bf5 6.e3" },
  { name: "La Défense Hollandaise", suite_de_coups: "1.d4 f5 2.g3 Nf6 3.Bg2 g6 4.Nf3 Bg7 5.O-O O-O 6.c4" }
]

openings.each do |opening|
  Opening.create!(opening)
end
