# frozen_string_literal: true
module Mutations
  class CreateInvoice < BaseMutation
    null true

    argument :invoice_cred, Types::InvoiceCredentialsInput, required: false

    type Types::InvoiceType

    def resolve(invoice_cred: nil)
      return unless invoice_cred

      context[:current_user].nil? do
        raise GraphQL::ExecutionError, "You need to authenticate to perform this action"
      end

      if User.where(id: context[:current_user]&.id).select("role") != "admin"
        raise GraphQL::ExecutionError, "You have to be admin"
      end

      Invoice.create!(
        user_id: invoice_cred[:user_id],
        request_id: invoice_cred[:request_id],
        room_id: invoice_cred[:room_id],
        amount_due: invoice_cred[:amount_due],
        paid: false
      )


    end

  end
end
