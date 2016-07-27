class Room
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :messages

  field :name

  def channel_name
    "rooms.#{self.id}"
  end
end
