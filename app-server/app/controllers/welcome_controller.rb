class WelcomeController < ApplicationController
  def index
    @room = Room.find_by(name: 'general')
    render :index
  end
end
