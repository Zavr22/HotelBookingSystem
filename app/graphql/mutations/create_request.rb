# frozen_string_literal: true

module Mutations
  # class CreateRequest contains method which creates request
  class CreateRequest < BaseMutation
    null true

    argument :req_input, Types::RequestInput, required: false

    type Types::RequestType

    def resolve(req_input: nil)
      return unless req_input

      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action' if context[:current_user].nil?

      Request.create!(
        capacity: req_input[:capacity],
        apart_class: req_input[:apart_class],
        duration: req_input[:duration],
        user: context[:current_user]
      )
    end
  end
end
