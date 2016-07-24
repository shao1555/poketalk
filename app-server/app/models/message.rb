class Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :room
  belongs_to :user

  field :body
end
