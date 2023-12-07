# frozen_string_literal: true

module Mutations
  # CreateUser is a class which contains method to create user
  class CreateUser < BaseMutation
    # class AuthProviderSignupData is used to declare argument credentials
    class AuthProviderSignupData < Types::BaseInputObject
      argument :credentials, Types::AuthCredentialsInput, required: false
    end

    argument :auth_provider, AuthProviderSignupData, required: false

    type Types::UserType

    def resolve(auth_provider: nil)
      user = User.new(
        login: auth_provider&.[](:credentials)&.[](:login),
        password: auth_provider&.[](:credentials)&.[](:password),
        role: auth_provider&.[](:credentials)&.[](:role)
      )
      if user.save
        {
          user: user,
          error_message: nil
        }
      else
        {
          user: nil,
          error_message: user.errors.full_messages
        }
      end
    end
  end
end
