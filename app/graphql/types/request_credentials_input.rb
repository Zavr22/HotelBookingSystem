# frozen_string_literal: true

module Types
  # class RequestCredentialsInput
  class RequestCredentialsInput < BaseInputObject
    graphql_name 'REQUEST_CREDENTIALS_INPUT'

    argument :capacity, Integer, required: true
    argument :apart_class, String, required: true
    argument :duration, Integer, required: true
  end
end
