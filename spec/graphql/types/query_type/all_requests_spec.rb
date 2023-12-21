# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allRequests' do
    let(:current_user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: current_user } }

    def execute_query(query)
      HotelSystemSchema.execute(query, context: context).to_h
    end

    it 'returns all requests when no filters are applied' do
      FactoryBot.create_list(:request, 3)
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

    it 'should return sorted requests' do
      request1 = FactoryBot.create(:request, apart_class: 'Economy', capacity: 2, check_in_date: '2023-01-10',
                                             created_at: 1.day.ago)
      request2 = FactoryBot.create(:request, apart_class: 'Luxury', capacity: 3, check_in_date: '2023-01-11',
                                             created_at: 2.days.ago)
      request3 = FactoryBot.create(:request, apart_class: 'Standard', capacity: 4, check_in_date: '2023-01-12',
                                             created_at: 3.days.ago)

      query = %(query{
                    allRequests(sort: {
                      createdAt: ASC
                    }){
                      apartClass
                      capacity
                      checkInDate
                      createdAt
                    }
                  })
      result = execute_query(query)
      puts result
      response_requests = result['data']['allRequests']
      expect(response_requests[0]['apartClass']).to eq(request3.apart_class)
      expect(response_requests[1]['apartClass']).to eq(request2.apart_class)
      expect(response_requests[2]['apartClass']).to eq(request1.apart_class)
    end
  end
end
