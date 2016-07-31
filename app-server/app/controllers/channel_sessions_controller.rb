class ChannelSessionsController < ApplicationController
  def new
    url = URI.parse(ENV['CHANNEL_SERVERS'].split(',').sample)
    url_params = {}
    if params[:room_id]
      url.path = "/rooms/#{params[:room_id]}"
    end

    %i(location distance).each do |field|
      url_params[field] = params[field] if params[field].present?
    end

    url.query = url_params.to_query

    render :show, locals: { url: url.to_s }
  end
end
