class RoomsController < ApplicationController
  before_action :set_room, only: %i(show)

  def index
    @rooms = Room.all
  end

  def show
  end

  def set_room
    @room = params[:id] =~ /[0-9a-f]{24}/ ? Room.find(params[:id]) : Room.find_by(name: params[:id])
  end
end
