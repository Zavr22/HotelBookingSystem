# frozen_string_literal: true

require 'test_helper'

class Mutations::CreateInvoiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:admin)
    @invoice_cred = {
      user_id: users(:admin).id,
      request_id: requests(:one).id,
      room_id: rooms(:one).id,
      amount_due: 100.0,
    }
    @context = { current_user: @user }
  end

  test 'creates an invoice when invoice_cred is valid and user is authenticated admin' do
    assert_difference('Invoice.count') do
      Mutations::CreateInvoice.new(object: nil, field: nil, context: @context).resolve(invoice_cred: @invoice_cred)
    end
  end

  test 'raises an error when current_user is not authenticated' do
    @context[:current_user] = nil

    assert_raises(GraphQL::ExecutionError) do
      Mutations::CreateInvoice.new(object: nil, field: nil, context: @context).resolve(invoice_cred: @invoice_cred)
    end
  end

  test 'raises an error when user is not an admin' do
    @context[:current_user] = users(:one)

    assert_raises(GraphQL::ExecutionError) do
      Mutations::CreateInvoice.new(object: nil, field: nil, context: @context).resolve(invoice_cred: @invoice_cred)
    end
  end

  test 'does not create an invoice when invoice_cred is nil' do
    assert_no_difference('Invoice.count') do
      Mutations::CreateInvoice.new(object: nil, field: nil, context: @context).resolve(invoice_cred: nil)
    end
  end
end


