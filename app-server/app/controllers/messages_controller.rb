class MessagesController < ApplicationController
  before_action :set_room

  def create
    @message = @room.messages.create(message_params.merge(user: session[:current_user]))
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def set_room
    @room = Room.find(params[:room_id])
  end
end
