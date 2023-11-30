# frozen_string_literal: true

module Types
  # class RequestInput
  class RequestInput < BaseInputObject
    graphql_name 'REQUEST_INPUT'

    argument :capacity, Integer, required: true
    argument :apart_class, String, required: true
    argument :duration, Integer, required: true
  end
end
