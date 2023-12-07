# frozen_string_literal: true

module Types
  # class RequestType
  class RequestType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField
    implements ::Types::SomeInterface
    field :user_id, Integer, null: false
    field :capacity, Integer
    field :apart_class, Enums::RoomClassType, null: false, description: "Room class"
    field :duration, Integer
    field :room, Types::RoomType
    field :check_in_date, GraphQL::Types::ISO8601Date
    field :check_out_date, GraphQL::Types::ISO8601Date
  end
end
