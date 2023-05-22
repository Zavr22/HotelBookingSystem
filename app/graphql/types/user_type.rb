# frozen_string_literal: true

module Types
  # class UserType
  class UserType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField
    implements ::Types::SomeInterface
    field :login, String
    field :password, String
    field :role, Enums::UserRoleType, null: false, description: "User permission level."
    field :requests, [Types::RequestType], null: true
    field :invoices, [Types::InvoiceType], null: true
  end
end
