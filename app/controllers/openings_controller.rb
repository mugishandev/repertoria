class OpeningsController < ApplicationController
  before_action :set_opening, only: [:show, :description, :explanation, :resources, :tab_content]
  def index
    @last_update = DataAnalyzer.maximum(:updated_at)
  end

  def show
    @opening = Opening.find(params[:id])
  end

  def description
    render partial: "description"
  end

  def explanation
    render partial: "explanation"
  end

  def resources
    render partial: "resources"
  end

  def tab_content
    render partial: "tab_content"
  end

  private

  def set_opening
    @opening = Opening.find(params[:id])
  end

end
