# spec/graphql/types/query_type_spec.rb
require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allRequests' do
    let(:current_user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: current_user } }
    let(:query) do
      %(query {
        allRequests {
          id
          userId
          apartClass
          duration
          createdAt
          updatedAt
        }
      })
    end

    subject(:result) do
      HotelSystemSchema.execute(query, context: context).to_h
    end

    before do
      FactoryBot.create_list(:request, 3)
    end

    it 'returns all requests' do
      expect(result.dig('data', 'allRequests')&.length).to eq(Request.count)
    end
  end

  describe 'allInvoices' do
    let(:user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: user } }
    let(:query) do
      %(query {
        allInvoices {
          id
          paid
          createdAt
          amountDue
          userId
        }
      })
    end

    subject(:result) do
      HotelSystemSchema.execute(query, context: context).to_h
    end

    before do
      FactoryBot.create(:invoice, user: user)
      FactoryBot.create(:invoice, user: user)
    end

    it 'returns all invoices for the current user' do
      expect(result.dig('data', 'allInvoices')&.length).to eq(2)
    end
  end
end
