require_relative '../mutations/create_user'
require_relative '../mutations/sign_in_user'

module Types
  class MutationType < Types::BaseObject

    field :create_user, mutation: Mutations::CreateUser
    field :signin_user, mutation: Mutations::SignInUser

  end
end
