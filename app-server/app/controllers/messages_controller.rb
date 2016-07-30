class MessagesController < ApplicationController
  def index
    @messages = Message.all
    if params[:room_id].present?
      room = Room.find(params[:room_id])
      @messages = @messages.where(room: room)
    end
  end

  def create
    @message = current_user.messages.create(message_params)
    render :show
  end

  def message_params
    params.require(:message).permit(:room_id, :body, :location_visible, :image_url, location: %i(latitude longitude))
  end
end
