# frozen_string_literal: true

module Mutations
  class CreateRequest < BaseMutation
    null true

    argument :reqCredentials, Types::RequestCredentialsInput, required: false

    type Types::RequestType

    def resolve(reqCredentials: nil )

      return unless reqCredentials

      context[:current_user].nil? do
        raise GraphQL::ExecutionError, "You need to authenticate to perform this action"
      end

      Request.create!(
        capacity: reqCredentials[:capacity],
        apart_class: reqCredentials[:apart_class],
        duration: reqCredentials[:duration],
        user: context[:current_user]
      )

    end
  end
end

