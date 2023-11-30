# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateRoom do
    let(:user) { FactoryBot.create(:user, :admin) }
    let(:context) { { current_user: user } }
    let(:room_input) do
      {
        name: "test",
        room_class: "Luxury",
        room_number: 12,
        total_count: 5,
        free_count: 5,
        price: 150
      }
    end
    let(:mutation) { described_class.new(object: nil, context: context, field: nil) }

    describe '#resolve' do
      context 'when room input is valid and user is authenticated admin' do
        it 'creates an invoice' do
          expect { mutation.resolve(room_input: room_input) }.to change { Room.count }.by(1)
        end
      end

      context 'when current_user is not authenticated' do
        let(:context) { { current_user: nil } }

        it 'raises an error' do
          expect { mutation.resolve(room_input: room_input) }.to raise_error(GraphQL::ExecutionError, 'You need to authenticate to perform this action')
        end
      end

      context 'when user is not an admin' do
        let(:user) { FactoryBot.create(:user) }

        it 'raises an error' do
          expect { mutation.resolve(room_input: room_input) }.to raise_error(GraphQL::ExecutionError, 'You have to be admin')
        end
      end

      context 'when invoice_cred is nil' do
        it 'does not create an invoice' do
          expect { mutation.resolve(room_input: nil) }.not_to change { Room.count }
        end
      end
    end
  end
end
