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

    def query(user_id:, request_id:, room_id:)
      <<~GQL
        mutation {
          createInvoice(
            input: {
              invoiceInput:{
              userId: #{user_id}
              requestId: #{request_id}
              roomId: #{room_id}
              amountDue: 100.0
            }
            }
          ) {
              invoice{
                id
              },
              errorMessage
          }
        }
      GQL
    end

    let(:mutation) { query(user_id: user.id, request_id: request.id, room_id: room.id) }

    subject(:result) do
      HotelSystemSchema.execute(mutation, context: context).to_h
    end

    describe '#resolve' do
      context 'when invoice_cred is valid and user is authenticated admin' do
        it 'creates an invoice' do
          expect(result['data']['createInvoice']['invoice']['id']).to eq(Invoice.last.id.to_s)
          expect(result['data']['createInvoice']['error_message']).to be_nil
        end
      end

      context 'when current_user is not authenticated' do
        let(:context) { { current_user: nil } }

        it 'raises an error' do
          puts result
          expect(result['errors'].first['message']).to eq('You need to authenticate to perform this action')
        end
      end

      context 'when user is not an admin' do
        let(:user) { FactoryBot.create(:user) }

        it 'raises an error' do
          expect(result['errors'].first['message']).to eq('You have to be admin')
        end
      end

      context 'when invoice_cred is nil' do
        it 'does not create an invoice' do
          expect {result}.not_to change { Invoice.count }
        end
      end
    end
  end
end
