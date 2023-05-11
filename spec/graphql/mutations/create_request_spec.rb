# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateRequest do
    describe '#resolve' do
      let(:user) { FactoryBot.create(:user) }
      let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
      let(:req_credentials) do
        {
          capacity: 2,
          apart_class: 'lux',
          duration: 5
        }
      end

      context 'when the user is authenticated' do
        it 'creates a new request' do
          expect { mutation.resolve(req_credentials: req_credentials) }.to change { Request.count }.by(1)

          request = Request.last
          expect(request.user_id).to eq(user.id)
          expect(request.capacity).to eq(req_credentials[:capacity])
          expect(request.apart_class).to eq(req_credentials[:apart_class])
          expect(request.duration).to eq(req_credentials[:duration])
        end
      end

      context 'when the user is not authenticated' do
        let(:mutation) { described_class.new(object: nil, context: { current_user: nil }, field: nil) }
        let(:req_credentials) do
          {
            capacity: 2,
            apart_class: 'lux',
            duration: 5,
            user_id: user.id
          }
        end

        it 'raises an error' do
          expect { mutation.resolve(req_credentials: req_credentials) }.to raise_error(GraphQL::ExecutionError)
        end
      end
    end
  end
end
