# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateInvoice do
    let(:user) { FactoryBot.create(:user, :admin) }
    let(:request) { FactoryBot.create(:request) }
    let(:room) { FactoryBot.create(:room) }
    let(:context) { { current_user: user } }
    let(:invoice_input) do
      {
        user_id: user.id,
        request_id: request.id,
        room_id: room.id,
        amount_due: 100.0
      }
    end
    let(:mutation) { described_class.new(object: nil, context: context, field: nil) }

    describe '#resolve' do
      context 'when invoice_cred is valid and user is authenticated admin' do
        it 'creates an invoice' do
          expect { mutation.resolve(invoice_cred: invoice_input) }.to change { Invoice.count }.by(1)
        end
      end

      context 'when current_user is not authenticated' do
        let(:context) { { current_user: nil } }

        it 'raises an error' do
          expect { mutation.resolve(invoice_input: invoice_input) }.to raise_error(GraphQL::ExecutionError, 'You have to be admin')
        end
      end

      context 'when user is not an admin' do
        let(:user) { FactoryBot.create(:user) }

        it 'raises an error' do
          expect { mutation.resolve(invoice_input: invoice_input) }.to raise_error(GraphQL::ExecutionError, 'You have to be admin')
        end
      end

      context 'when invoice_cred is nil' do
        it 'does not create an invoice' do
          expect { mutation.resolve(invoice_input: nil) }.not_to change { Invoice.count }
        end
      end
    end
  end
end
