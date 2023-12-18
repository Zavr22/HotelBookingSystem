# frozen_string_literal: true

module Mutations
  # class CreateRequest contains method which creates request
  class CreateRequest < BaseMutation
    null true

    argument :req_input, Types::RequestInput, required: false

    field :request, Types::RequestType, null: true
    field :error_message, String, null: true

    def resolve(req_input: nil)
      return unless req_input

      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action' if context[:current_user].nil?

      request = Request.new(
        capacity: req_input[:capacity],
        apart_class: req_input[:apart_class],
        user: context[:current_user],
        check_in_date: req_input[:check_in_date],
        check_out_date: req_input[:check_out_date],
        duration: req_input[:check_out_date] - req_input[:check_in_date],
        room_id: req_input[:room_id]
      )
      if request.save
        {
          request: request,
          error_message: nil
        }
      else
        {
          request: nil,
          error_message: request.errors.full_messages
        }
      end
    end
  end
end
