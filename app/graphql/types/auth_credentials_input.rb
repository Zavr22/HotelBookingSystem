# frozen_string_literal: true

module Types
  # class AuthCredentialsInput
  class AuthCredentialsInput < Types::BaseInputObject

    graphql_name 'AUTH_PROVIDER_CREDENTIALS'

    argument :login, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true

  end
end


