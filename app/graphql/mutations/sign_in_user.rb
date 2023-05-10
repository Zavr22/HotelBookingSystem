# frozen_string_literal: true

module Mutations
  # class SignIn user contains method to sign in user
  class SignInUser < BaseMutation
    null true

    argument :credentials, Types::AuthCredentialsInput, required: false

    field :token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(credentials: nil)
      return unless credentials

      return unless (user = User.find_by(login: credentials[:login], password: credentials[:password]))

      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{user.id}")

      context[:session][:token] = token

      { user: user, token: token }
    end
  end
end
