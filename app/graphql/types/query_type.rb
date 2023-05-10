# frozen_string_literal: true

require_relative '../resolvers/requests_search'

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

    def all_requests
      if User.where(id: context[:current_user]&.id).select('role') != 'admin'
        raise GraphQL::ExecutionError, 'You need to be admin to perform this action'
      end

      Request.all
    end

    def all_invoices
      user_id = context[:current_user]&.id
      role = User.where(id: context[:current_user]&.id).select('role')

      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action' if context[:current_user].nil?

      if role == 'admin'
        Invoice.all
      elsif role == 'user'
        Invoice.where(user_id: user_id)
      end
    end
  end
end
