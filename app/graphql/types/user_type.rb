# frozen_string_literal: true

module Types
  # class UserType
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :login, String
    field :password, String
    field :role, Enums::UserRoleType, null: false, description: "User permission level."
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :requests, Types::RequestType, null: true
    field :invoices, Types::InvoiceType, null: true
  end
end
