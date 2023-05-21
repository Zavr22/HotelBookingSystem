# frozen_string_literal: true

module Types
  # class QueryType
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField



    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :all_requests, [RequestType], null: true, resolver: Resolvers::RequestsSearch
    field :all_invoices, [InvoiceType], null: true, resolver: Resolvers::InvoiceSearch
    field :all_users, [UserType], null: false
    def all_users
      raise GraphQL::ExecutionError, "Ypu have to authorize as admin" if context[:current_user].nil?
      raise GraphQL::ExecutionError, "You have to be admin to perform this action" unless UserPolicy.new(@context[:current_user], nil).user_is_admin?
      User.all
    end
  end
end
