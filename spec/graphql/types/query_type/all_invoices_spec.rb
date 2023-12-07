# spec/graphql/types/all_invoices_spec.rb
require 'rails_helper'

RSpec.describe Types::QueryType do

  describe 'allInvoices' do
    let(:user) { FactoryBot.create(:user, :admin) }
    let(:context) { {current_user: user} }
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
      HotelSystemSchema.execute(query, context: context)
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
