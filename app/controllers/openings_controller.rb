class OpeningsController < ApplicationController
  def index
    @last_update = DataAnalyzer.maximum(:updated_at)
  end

  def show
  end
end
