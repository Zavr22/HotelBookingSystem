# frozen_string_literal: true

module Mutations
  # class CreateInvoice is a class which contains method creating invoice by admin
  class CreateInvoice < BaseMutation
    null true

    argument :invoice_input, Types::InvoiceInput, required: false

    field :invoice, Types::InvoiceType, null: true
    field :error_message, String, null: true

    def resolve(invoice_input: nil)
      return unless invoice_input
      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action' unless InvoicePolicy.new(
        @context[:current_user], nil
      ).user_is_authenticated?
      raise GraphQL::ExecutionError, 'You have to be admin' unless InvoicePolicy.new(@context[:current_user], nil).user_is_admin?

      invoice = Invoice.new(
        user_id: invoice_input[:user_id],
        request_id: invoice_input[:request_id],
        room_id: invoice_input[:room_id],
        amount_due: invoice_input[:amount_due],
        paid: false
      )
      UserInvoiceMailer.new.invoice_email(@context[:current_user])
      Room.where(room_id: invoice_input[:room_id]).update_all(free_count: free_count - 1)
      if invoice.save
        {
          invoice: invoice,
          error_message: nil
        }
      else
        {
          invoice: nil,
          error_message: invoice.errors.full_messages
        }
      end
    end
  end
end
