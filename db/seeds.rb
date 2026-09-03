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
  { name: "L'Italienne", suite_de_coups: "1. e4 e5, 2. Nf3 Nc6, 3. Bc4", color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=5Ny8I1Bj-ek", image: "board_italienne.png", explications: [{image: "board_italian_e4", description: "Contrôle le centre et libère ton fou et ta dame."}, {image: "board_italian_Nf3", description: "Développe ton cavalier et attaque le pion e5."}, {image: "board_italian_Bc4", description: "Développe ton fou et vise f7, le point faible du camp noir"}], logo: "knight_bleu" },
  { name: "L'Écossaise", suite_de_coups: "1. e4 e5, 2. Nf3 Nc6, 3. d4", color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=nWWe_byE3gM", image: "board_ecossaise.png", explications: [{image: "board_ecossaise_e4", description: "Contrôle le centre et libère ton fou et ta dame."}, {image: "board_ecossaise_Nf3", description: "Développe ton cavalier et attaque le pion e5."}, {image: "board_ecossaise_d4", description: "Attaque le centre et mets immédiatement la pression sur le pion e5."}], logo: "knight_bleu" },
  { name: "Le Système de Londres", suite_de_coups: "1. d4 d5, 2. Nf3 Nf6, 3. Bf4", color: "white", against: nil, video_url: "https://www.youtube.com/watch?v=k86o1Wql56c", image: "board_systeme_londres", explications: [{image: "board_london_d4", description: "Contrôle le centre et libère ton fou."}, {image: "board_london_Nf3", description: "Développe ton cavalier et prépare ton roque."}, {image: "board_london_Bf4", description: "Sors ton fou avant de jouer e3 et place-le sur une case active."}], logo: "knight_bleu" },
  { name: "La Scandinave", suite_de_coups: "1. e4 d5", color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=1wHJGyWGVLA", image: "board_scandinave", explications: [{image: "board_scandinave", description: "Attaque immédiatement le pion e4 et conteste le centre."}], logo: "pawn_bleu" },
  { name: "La Française", suite_de_coups: "1. e4 e6", color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=vVz6xqqtP1U", image: "board_francaise", explications: [{image: "board_francaise", description: "Prépare la poussée d5 pour contester le centre et libère ton fou de cases noires."}], logo: "pawn_bleu" },
  { name: "La Caro-Kann", suite_de_coups: "1. e4 c6", color: "black", against: "e4", video_url: "https://www.youtube.com/watch?v=hlL9WW5tAUw", image: "board_caro_kann", explications: [{image: "board_caro_kann", description: "Prépare la poussée d5 pour contester le centre tout en gardant ton fou libre."}], logo: "pawn_bleu" },
  { name: "Le Gambit Dame refusé", suite_de_coups: "1. d4 d5, 2. c4 e6", color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=pE2cSSJdYRY", image: "board_gambit_dame_refuse", explications: [{image: "board_gambit_dame_refuse_d5", description: "Conteste le centre et empêche les Blancs de s'y installer seuls."}, {image: "board_gambit_dame_refuse_e6", description: "Renforce ton pion d5 et refuse de prendre le pion offert en c4."}], logo: "pawn_bleu" },
  { name: "La Défense Slave", suite_de_coups: "1. d4 d5, 2. c4 c6", color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=_oHHm7MZAO8", image: "board_slave", explications: [{image: "board_slave_d5", description: "Conteste le centre avec ton propre pion."}, {image: "board_slave_c6", description: "Renforce ton pion d5 tout en gardant ton fou de cases blanches libre."}], logo: "pawn_bleu" },
  { name: "La Défense Hollandaise", suite_de_coups: "1. d4 f5", color: "black", against: "d4", video_url: "https://www.youtube.com/watch?v=nD6bXC6RQkM", image: "board_hollandaise", explications: [{image: "board_hollandaise", description: "Contrôle la case e4 et commence immédiatement à jouer de manière agressive sur l'aile roi."}], logo: "pawn_bleu" }
]

openings.each do |opening|
  Opening.create!(opening)
end
 puts "Seeded #{Opening.count} openings."
