# frozen_string_literal: true
require_relative '../mutations/create_user'
require_relative '../mutations/sign_in_user'
require_relative '../mutations/create_request'
require_relative '../mutations/create_invoice'

module Types
  # class MutationType
  class MutationType < Types::BaseObject
    field :create_user, mutation: Mutations::CreateUser
    field :signin_user, mutation: Mutations::SignInUser
    field :create_request, mutation: Mutations::CreateRequest
    field :create_invoice, mutation: Mutations::CreateInvoice
  end
end
