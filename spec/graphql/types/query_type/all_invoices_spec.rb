# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allInvoices' do
    let(:current_user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: current_user } }
    
    def execute_query(query)
      HotelSystemSchema.execute(query, context: context).to_h
    end

    it 'returns all invoices when no filters or sorting are applied' do
      query = 
        %(query {
        allInvoices {
          id
          paid
          createdAt
          amountDue
          userId
        }
      })
      result = execute_query(query)
      puts result
      expect(result.dig('data', 'allInvoices')&.length).to eq(Invoice.count)
    end

    it 'returns invoices sorted by created_at in ascending order' do
      puts result
      query_with_sort = %(query {
        allInvoices(orderby: createdAt_ASC) {
          id
          paid
          createdAt
          amountDue
          userId
        }
      })

      sorted_result = execute_query(query_with_sort)
      puts sorted_result
      expect(sorted_result.dig('data', 'allInvoices')&.length).to eq(Invoice.count)
      expect(sorted_result.dig('data', 'allInvoices').map { |invoice| invoice['createdAt'] }).to eq(
        sorted_result.dig('data', 'allInvoices').map { |invoice| invoice['createdAt'] }.sort
      )
    end

  end
end
