SYSTEM_PROMPT = ""

class DataAnalyzer < ApplicationRecord
  belongs_to :user
  belongs_to :opening

  def analyse
    @games = Game.fetch_from_chess_com("mjnk")

    ruby_llm_chat = RubyLLM.chat
    response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@games.content)
  end
end
