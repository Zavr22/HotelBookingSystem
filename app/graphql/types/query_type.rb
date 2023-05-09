module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :all_requests, [RequestType], null: true
    field :get_users_invoices, [RequestType], null:true

    def all_requests
      return raise GraphQL::ExecutionError, "You need to be admin to perform this action" unless User.find_by(id: context[:current_user]&.id)&.role == "admin"

      Request.all
    end

    def get_users_invoices
      context[:current_user].nil? do
        raise GraphQL::ExecutionError, "You need to authenticate to perform this action"
      end

      Invoice.where(user_id: context[:current_user]&.id).all
    end


  end
end
