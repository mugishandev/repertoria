class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def about
  end

  def legals
  end

  def cgu
  end

  def confidentials
  end
end
