class Message
  include Mongoid::Document
  include Mongoid::Geospatial
  include Mongoid::Timestamps::Created

  belongs_to :room
  belongs_to :user

  field :body
  field :location, type: Point, sphere: true
  field :image_url
  field :location_visible, type: Boolean, default: false

  index({room_id: 1, created_at: 1})
  index({user_id: 1, created_at: 1})
  sphere_index :location

  validates_presence_of :body, if: -> { !location_visible && image_url.blank? }
  validates_format_of :image_url, with: /\A#{Regexp.escape(ImageUploadTicketsController::RESOURCE_URL)}.*\z/, allow_blank: true

  after_create :publish_to_redis

  def to_json
    builder = JbuilderTemplate.new(ApplicationController.new.view_context)
    builder.partial! 'messages/message', locals: { message: self, filter: false }
    builder.target!
  end

  def publish_to_redis
    $redis.publish(room.channel_name, self.to_json)
  end
end
