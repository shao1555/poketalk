class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :messages

  field :name

  index({created_at: 1})

  validates_presence_of :name
end
