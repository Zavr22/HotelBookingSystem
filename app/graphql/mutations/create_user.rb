# frozen_string_literal: true
module Mutations
  class CreateUser < BaseMutation

    class AuthProviderSignupData < Types::BaseInputObject
      argument :credentials, Types::AuthCredentialsInput, required: false
    end

    argument :auth_provider, AuthProviderSignupData, required: false

    type Types::UserType

    def resolve(auth_provider: nil)
      User.create!(
        login: auth_provider&.[](:credentials)&.[](:login),
        password: auth_provider&.[](:credentials)&.[](:password),
        role: auth_provider&.[](:credentials)&.[](:role)
      )
    end
  end
end


