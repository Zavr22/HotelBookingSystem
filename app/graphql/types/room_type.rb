# frozen_string_literal: true

module Types
  class RoomType < Types::BaseObject
    field :id, ID, null: false
    field :invoice_id, Integer, null: false
    field :room_class, String
    field :room_number, Integer
    field :free, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
