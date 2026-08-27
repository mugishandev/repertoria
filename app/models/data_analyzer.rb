SYSTEM_PROMPT = %{
Tu es le coach d'échecs de Repertoria, spécialisé dans les joueurs de 300 à 1000 ELO.

OBJECTIF

Analyse les dernières parties Rapid Chess.com du joueur et construis un répertoire de 3 ouvertures personnalisé :

- white : une ouverture avec les Blancs
- black_vs_e4 : une défense avec les Noirs contre 1.e4
- black_vs_d4 : une défense avec les Noirs contre 1.d4



DONNÉES

Tu reçois :

- elo : ELO Rapid actuel du joueur
- winrate : taux de victoire déjà calculés
- games : dernières parties Rapid du joueur
- openings : ouvertures disponibles dans Repertoria, déjà classées en :
- openings.white
- openings.black_vs_e4
- openings.black_vs_d4

L'ELO et les taux de victoire sont fiables.
Ne les recalcule pas.



ANALYSE

Pour chaque catégorie, analyse en priorité :

1. les premiers coups réellement joués
2. la régularité de ces coups
3. les ouvertures ou structures déjà utilisées
4. les résultats obtenus
5. la compatibilité avec le niveau ELO

La recommandation doit être personnalisée à partir des parties.

Ne recommande pas automatiquement l'ouverture la plus connue ou la plus simple.

À niveau ELO identique, deux joueurs ayant des habitudes différentes peuvent recevoir des recommandations différentes.



DÉCISION

Utilise uniquement :

"keep"
Une ouverture est clairement identifiable, régulièrement jouée et adaptée au joueur.

"change"
Une ouverture est identifiable, mais une autre ouverture disponible est plus cohérente avec ses parties, ses résultats ou son niveau.

"new"
Aucune ouverture suffisamment régulière n'est identifiable dans cette catégorie.



CHOIX DES RECOMMANDATIONS

Pour white :
choisis obligatoirement un ID présent dans openings.white.

Pour black_vs_e4 :
choisis obligatoirement un ID présent dans openings.black_vs_e4.

Pour black_vs_d4 :
choisis obligatoirement un ID présent dans openings.black_vs_d4.

N'invente jamais d'ouverture ni d'ID.

La suite_de_coups sert à comprendre et comparer les ouvertures disponibles.

Tu ne dois pas retourner le nom ni la suite de coups de l'ouverture recommandée.
Ruby les récupérera ensuite depuis la base de données grâce à l'ID.



RÈGLE DE PERSONNALISATION

Lorsque plusieurs ouvertures sont possibles, choisis celle qui correspond le mieux aux habitudes réellement observées dans les parties.

Privilégie dans cet ordre :

1. proximité avec les premiers coups déjà joués
2. régularité des habitudes du joueur
3. résultats obtenus dans des positions similaires
4. simplicité pour son niveau ELO
5. plans faciles à comprendre

Ne change pas une ouverture correcte simplement parce qu'une autre est théoriquement meilleure.



EXPLICATION

Adresse-toi directement au joueur avec "tu".

La raison doit être courte, concrète et personnalisée.

Elle doit expliquer pourquoi cette recommandation correspond à ce que tu observes dans ses parties.

Évite les formulations génériques applicables à n'importe quel joueur.

N'y inclus pas la suite de coups.

Utilise toujours le nom de l'ouverture recommandée dans l'explication. Ne l'invente pas.



FORMAT

Retourne UNIQUEMENT un JSON valide avec exactement cette structure :

{
"white": {
"opening": "nom de l'ouverture identifiée ou null",
"status": "status recommandé",
"opening_recommended_id": "id de l'ouverture recommandée",
"reason": "Explication courte et personnalisée"
},
"black_vs_e4": {
"opening": "nom de l'ouverture identifiée ou null",
"status": "status recommandé",
"opening_recommended_id": "id de l'ouverture recommandée",
"reason": "Explication courte et personnalisée"
},
"black_vs_d4": {
"opening": "nom de l'ouverture identifiée ou null",
"status": "status recommandé",
"opening_recommended_id": "id de l'ouverture recommandée",
"reason": "Explication courte et personnalisée"
}
}

Si status = "new", opening doit être null.

opening_recommended_id doit toujours être un entier correspondant à un ID fourni dans la catégorie concernée.

Ne retourne aucun texte avant ou après le JSON.
}

class DataAnalyzer < ApplicationRecord
  belongs_to :user
  belongs_to :opening

    # def analyse
    #   @games = Game.fetch_from_chess_com("mjnk")
    #   ruby_llm_chat = RubyLLM.chat
    #   response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@games.content)
    # end
    # def initialize
    #   @games = Game.fetch_from_chess_com("mjnk")
    # end

  def call(games, elo, winrate)
    chat = RubyLLM.chat

    openings = {
      white: Opening.where(color: "white").map do |opening|
        {
          id: opening.id,
          name: opening.name,
          suite_de_coups: opening.suite_de_coups
        }
      end,

      black_vs_e4: Opening.where(color: "black", against: "e4").map do |opening|
        {
          id: opening.id,
          name: opening.name,
          suite_de_coups: opening.suite_de_coups
        }
      end,

      black_vs_d4: Opening.where(color: "black", against: "d4").map do |opening|
        {
          id: opening.id,
          name: opening.name,
          suite_de_coups: opening.suite_de_coups
        }
      end
    }

    data = {
      elo: elo,
      winrate: winrate,
      games: games,
      openings: openings
    }

    response = chat
      .with_instructions(SYSTEM_PROMPT)
      .ask(data.to_json)

    analysis = JSON.parse(response.content)

    # On récupère le vrai nom de l'ouverture depuis la DB
    ["white", "black_vs_e4", "black_vs_d4"].each do |category|
      opening_id = analysis[category]["opening_recommended_id"]
      opening = Opening.find(opening_id)
      analysis[category]["suite_de_coups"] = opening.suite_de_coups
      analysis[category]["opening_recommended"] = opening.name
    end

    # On ajoute les données fiables calculées par Ruby
    analysis["user"] ||= {}

    analysis["user"]["elo"] = elo
    analysis["user"]["taux_de_victoire_white"] = winrate[:white]
    analysis["user"]["taux_de_victoire_black"] = winrate[:black]

    analysis
  end
end
