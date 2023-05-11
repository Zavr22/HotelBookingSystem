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

    def all_requests
      current_user_id = context[:current_user]&.id

      if current_user_id
        user = User.find_by(id: current_user_id)

        if user && user.role == 'admin'
          Request.all
        else
          raise GraphQL::ExecutionError, 'You need to be admin to perform this action'
        end
      else
        raise GraphQL::ExecutionError, 'You need to be logged in to perform this action'
      end
    end


    def all_invoices
      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action' unless context[:current_user]

      user_id = context[:current_user]&.id
      role = User.where(id: context[:current_user]&.id).select('role')

      if role == 'admin'
        Invoice.all
      elsif role == 'user'
        Invoice.where(user_id: user_id)
      end
    end
  end
end
