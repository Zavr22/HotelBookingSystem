# frozen_string_literal: true

module Mutations
  # class CreateRequest contains method which creates request
  class CreateRequest < BaseMutation
    null true

    argument :req_credentials, Types::RequestCredentialsInput, required: false

    type Types::RequestType

    def resolve(req_credentials: nil)
      return unless req_credentials

      raise GraphQL::ExecutionError, "You need to authenticate to perform this action" if context[:current_user].nil?
      Request.create!(
        capacity: req_credentials[:capacity],
        apart_class: req_credentials[:apart_class],
        duration: req_credentials[:duration],
        user: context[:current_user]
      )
    end
  end
end
