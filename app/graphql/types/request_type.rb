# frozen_string_literal: true

module Types
  # class RequestType
  class RequestType < Types::BaseObject
    implements ::Types::SomeInterface
    field :user_id, Integer, null: false
    field :capacity, Integer
    field :apart_class, Enums::RoomClassType, null: false, description: "Room class"
    field :duration, Integer
  end
end
