class ChannelSessionsController < ApplicationController
  def new
    # TODO: 振り分けとか
    url = URI.parse('ws://127.0.0.1:8080/')
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
