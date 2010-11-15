class GamesController < ApplicationController

  def index
    @title = "Games"
  end

  def letters
    @title = "Letters"
  end

  def sketchpad
    @title = "Sketchpad"
  end

end
