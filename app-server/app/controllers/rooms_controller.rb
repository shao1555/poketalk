class RoomsController < ApplicationController
  before_action :set_room, only: %i(show)
  DEFAULT_DISTANCE = 5

  def index
    @rooms = Room.all
  end

  def show
    if params[:distance].present?
      @distance = params[:distance].to_i
    else
      @distance = DEFAULT_DISTANCE
    end
  end

  def set_room
    @room = params[:id] =~ /[0-9a-f]{24}/ ? Room.find(params[:id]) : Room.find_by(name: params[:id])
  end
end
