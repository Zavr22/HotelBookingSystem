# frozen_string_literal: true

module Types
  # class InvoiceType
  class InvoiceType < Types::BaseObject
    implements Interfaces::SomeInterface
    field :user_id, Integer, null: false
    field :request_id, Integer, null: false
    field :room_id, Integer
    field :amount_due, Float
    field :paid, Boolean
  end
end
