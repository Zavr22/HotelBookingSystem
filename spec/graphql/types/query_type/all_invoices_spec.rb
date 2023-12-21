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
      query_with_sort = %(query {
        allInvoices(sort:{ createdAt :ASC}) {
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
    it 'should return invoices sorted by amount due' do
      request = FactoryBot.create(:request, user: current_user)
      invoice1 = Invoice.create!(user_id: current_user.id, amount_due: 100.0, created_at: 2.days.ago, 
                                 request_id: request.id)
      invoice2 = Invoice.create!(user_id: current_user.id, amount_due: 200.0, created_at: 1.day.ago, 
                                 request_id: request.id)
      invoice3 = Invoice.create!(user_id: current_user.id, amount_due: 50.0, created_at: 3.days.ago, 
                                 request_id: request.id)
      query = %(
      query {
        allInvoices(sort: { amountDue: DESC }) {
          userId
          amountDue
        }
      }
    )

      result = execute_query(query)
      sorted_invoices = result['data']['allInvoices']

      expect(sorted_invoices[0]['amountDue']).to eq(invoice2.amount_due)
      expect(sorted_invoices[1]['amountDue']).to eq(invoice1.amount_due)
      expect(sorted_invoices[2]['amountDue']).to eq(invoice3.amount_due)
    end
  end
end
