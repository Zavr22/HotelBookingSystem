# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe QueryType do
    describe 'all_requests' do
      let(:query) { 'query { allRequests { id, userId, duration, apartClass } }' }

      context 'when the user is an admin' do
        let!(:admin) { FactoryBot.create(:user, role: 'admin') }
        let!(:user) { FactoryBot.create(:user, role: 'user') }
        let!(:requests) { FactoryBot.create_list(:request, 2, user: user) }

        it 'returns all requests' do
          result = HotelSystemSchema.execute(query, context: { current_user: admin })

          expect(result.dig('data', 'allRequests')).not_to be_nil
          expect(result.dig('data', 'allRequests').length).to eq(requests.count)
        end
      end

      context 'when the user is not an admin' do
        let!(:user) { FactoryBot.create(:user, role: 'user') }

        it 'raises an error' do
          expect {
            HotelSystemSchema.execute(query, context: { current_user: user })
          }.to raise_error(GraphQL::ExecutionError, 'You need to be admin')
        end
      end
    end

    describe 'all_invoices' do
      let(:query) { 'query { allInvoices { userId, requestId, roomId } }' }

      context 'when the user is an admin' do
        let!(:admin) { FactoryBot.create(:user, role: 'admin') }
        let!(:user) { FactoryBot.create(:user, role: 'user') }
        let!(:request) { FactoryBot.create(:request, user: user) }
        let!(:invoices) { FactoryBot.create_list(:invoice, 2, user: user, request: request) }

        it 'returns all invoices' do
          result = HotelSystemSchema.execute(query, context: { current_user: admin })

          expect(result.dig('data', 'allInvoices')).not_to be_nil
          expect(result.dig('data', 'allInvoices').length).to eq(invoices.count)
        end
      end

      context 'when the user is a regular user' do
        let!(:user) { FactoryBot.create(:user, role: 'user') }
        let!(:user_invoice) { FactoryBot.create(:invoice, user: user) }
        let!(:other_user_invoice) { FactoryBot.create(:invoice) }

        it 'returns only their invoices' do
          result = HotelSystemSchema.execute(query, context: { current_user: user })

          expect(result.dig('data', 'allInvoices')).not_to be_nil
          expect(result.dig('data', 'allInvoices').length).to eq(1)
          expect(result.dig('data', 'allInvoices').first['userId'].to_s).to eq(user.id.to_s)
        end
      end

      context 'when the user is not authenticated' do
        it 'raises an error' do
          expect {
            HotelSystemSchema.execute(query, context: { current_user: nil })
          }.to raise_error(GraphQL::ExecutionError, 'You need to authenticate to perform this action')
        end
      end
    end
  end
end
