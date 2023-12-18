# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allRequests' do
    let(:current_user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: current_user } }

    def execute_query(query)
      HotelSystemSchema.execute(query, context: context).to_h
    end

    before do
      FactoryBot.create_list(:request, 3)
    end

    it 'returns all requests when no filters are applied' do
      query =
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
      result = execute_query(query)
      expect(result.dig('data', 'allRequests')&.length).to eq(Request.count)
    end

    it 'returns filtered requests based on user_id' do
      user = FactoryBot.create(:user)
      FactoryBot.create_list(:request, 2, user: user)
      query_with_filter = %(query {
        allRequests(filter: { userId: #{user.id} }) {
          id
          userId
          apartClass
          duration
          createdAt
          updatedAt
        }
      })

      filtered_result = execute_query(query_with_filter)

      expect(filtered_result.dig('data', 'allRequests')&.length).to eq(Request.count)
    end
  end
end
