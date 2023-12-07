# frozen_string_literal: true

module Types
  # class RequestInput
  class RequestInput < BaseInputObject
    graphql_name 'REQUEST_INPUT'

    argument :capacity, Integer, required: true
    argument :apart_class, String, required: true
    argument :duration, Integer, required: false
    argument :room_id, Integer, required: true
    argument :check_in_date, GraphQL::Types::ISO8601Date, required: true
    argument :check_out_date, GraphQL::Types::ISO8601Date, required: true
  end
end
