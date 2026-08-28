class Opening < ApplicationRecord
  def color_fr
    {
      "white" => "Blancs",
      "black" => "Noirs"
    }[color]
  end
end
