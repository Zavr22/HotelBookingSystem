# frozen_string_literal: true

module Types
  # class InvoiceCredentialsInput
  class InvoiceCredentialsInput < BaseInputObject

    graphql_name 'INVOICE_INPUT_CREDENTIALS'

    argument :user_id, Integer, required: true
    argument :request_id, Integer, required: true
    argument :room_id, Integer, required: true
    argument :amount_due, Float, required: true
    argument :paid, Boolean, required: false
  end
end

