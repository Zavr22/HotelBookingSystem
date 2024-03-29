# frozen_string_literal: true

module Types
  # class RoomType
  class RoomType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField
    implements ::Types::SomeInterface
    field :room_class, Enums::RoomClassType, null: false, description: 'Room class'
    field :room_number, Integer
    field :total_count, Integer
    field :free_count, Integer
    field :price, Float
    field :name, String
    field :image, String, null: true, description: 'URL of the room image'
    def image
      object.image_url if object.image.attached?
    end
  end
end
