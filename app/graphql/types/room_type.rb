# frozen_string_literal: true

module Types
  # class RoomType
  class RoomType < Types::BaseObject
    implements Interfaces::SomeInterface
    field :room_class, String
    field :room_number, Integer
    field :free, Boolean
  end
end
