# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateRequest do
    describe '#resolve' do
      let(:user) { FactoryBot.create(:user) }
      let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
      let(:room) { FactoryBot.create(:room) }
      let(:req_input) do
        {
          capacity: 2,
          apart_class: 'Luxury',
          room_id: room.id,
          check_in_date: '2023-12-11',
          check_out_date: '2023-12-13'
        }
      end

      context 'when the user is authenticated' do
        it 'creates a new request' do
          expect { mutation.resolve(req_input: req_input) }.to change { Request.count }.by(1)

          request = Request.last
          expect(request.user_id).to eq(user.id)
          expect(request.capacity).to eq(req_input[:capacity])
          expect(request.apart_class).to eq(req_input[:apart_class])
          puts request.duration
        end
      end

      context 'when the user is not authenticated' do
        let(:mutation) { described_class.new(object: nil, context: { current_user: nil }, field: nil) }
        let(:req_input) do
          {
            capacity: 2,
            apart_class: 'Luxury',
            room_id: room.id,
            check_in_date: '2023-12-11',
            check_out_date: '2023-12-13',
            user: user.id
          }
        end
        it 'raises an error' do
          expect { mutation.resolve(req_input: req_input) }.to raise_error(GraphQL::ExecutionError)
        end
      end
    end
  end
end
