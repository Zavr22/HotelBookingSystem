# frozen_string_literal: true

module Mutations
  # class CreateInvoice is a class which contains method creating invoice by admin
  class CreateInvoice < BaseMutation
    null true

    argument :invoice_cred, Types::InvoiceCredentialsInput, required: false

    type Types::InvoiceType

    def resolve(invoice_cred: nil)
      return unless invoice_cred

      context[:current_user].nil? do
        raise GraphQL::ExecutionError, 'You need to authenticate to perform this action'
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
  def authorized?(_object)

    raise GraphQL::ExecutionError, "You aren't allowed to create an invoice" unless InvoicePolicy.new(@context[:current_user], nil).create?

    true
  end
end
