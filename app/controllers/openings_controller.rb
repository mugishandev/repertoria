class OpeningsController < ApplicationController
  def index
    @last_update = DataAnalyzer.maximum(:updated_at)
  end

  def show
    @opening = Opening.find(params[:id])
  end
end
