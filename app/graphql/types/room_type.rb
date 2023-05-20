# frozen_string_literal: true

module Types
  # class RoomType
  class RoomType < Types::BaseObject
    implements ::Types::SomeInterface
    field :room_class, Enums::RoomClassType, null: false, description: "Room class"
    field :room_number, Integer
    field :free, Boolean
  end
end
