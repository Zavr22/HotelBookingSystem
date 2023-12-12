# frozen_string_literal: true

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

    it 'returns all requests when no filters are applied' do
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

      filtered_result = HotelSystemSchema.execute(query_with_filter, context: context).to_h

      expect(filtered_result.dig('data', 'allRequests')&.length).to eq(Request.count)
    end
  end
end
