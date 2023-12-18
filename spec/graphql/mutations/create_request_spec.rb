# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateRequest do
    describe '#resolve' do
      let(:user) { FactoryBot.create(:user) }
      let(:room) { FactoryBot.create(:room) }
      let(:context) { { current_user: user } }
      let(:query) do
        <<~GQL
          mutation {
            createRequest(
              input: {
                reqInput: {
                  capacity: 2,
                  apartClass: "Luxury",
                  roomId: #{room.id},
                  checkInDate: "2023-12-11",
                  checkOutDate: "2023-12-13",
                }
              }
            ) {
                request{
                  id
                  duration
                },
    						errorMessage
            }
          }
        GQL
      end

      subject(:result) do
        HotelSystemSchema.execute(query, context: context).to_h
      end

      context 'when the user is authenticated' do
        it 'creates a new request' do
          puts result
          expect(result['data']['createRequest']['request']['id']).to eq(Request.last.id.to_s)
          expect(result['data']['createRequest']['errorMessage']).to be_nil
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
