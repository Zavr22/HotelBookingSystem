# frozen_string_literal: true

module Types
  # class InvoiceType
  class InvoiceType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :request_id, Integer, null: false
    field :room_id, Integer
    field :amount_due, Float
    field :paid, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
