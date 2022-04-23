class Room < ApplicationRecord
  validates_uniqueness_of :name, on: :create, message: 'Name of the room must be unique'
  scope :public_rooms, -> { where(:is_private => false)}
end
