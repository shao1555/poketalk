class Room
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :messages

  field :name
end
