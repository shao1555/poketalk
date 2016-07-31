class MessagesController < ApplicationController
  def index
    @messages = Message.all
    if params[:room_id].present?
      room = Room.find(params[:room_id])
      @messages = @messages.where(room: room)
    end

    # TODO: 過去ログを gap loading できるように拡張
    if params[:location].present? && params[:location] =~ /\d+\.\d+,\d+\.\d+/ && params[:distance].present?
      location = params[:location].split(',').map(&:to_f)
      point = Mongoid::Geospatial::Point.new(*location)
      @messages = @messages.where(location: {'$geoWithin' => {'$centerSphere' => point.radius_sphere(params[:distance].to_f, :km)} })
    end

    @messages = @messages.desc(:created_at).limit(20).reverse
  end

  def create
    # ログインしてない状態
    render nothing: true, status: :bad_request and return if current_user.nil?

    @message = current_user.messages.create(message_params)
    if @message.persisted?
      render :show
    else
      render nothing: true, status: :bad_request
    end
  end

  def show
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:room_id, :body, :location_visible, :image_url, location: %i(latitude longitude))
  end
end
