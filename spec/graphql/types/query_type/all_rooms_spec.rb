# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allRooms' do
    let(:current_user) { FactoryBot.create(:user, role: 'admin') }
    let(:context) { { current_user: current_user } }

    before do
      FactoryBot.create(:room, room_class: 'Economy', price: 100)
      FactoryBot.create(:room, room_class: 'Standard', price: 150)
      FactoryBot.create(:room, room_class: 'Luxury', price: 200)
    end

    def execute_query(query)
      HotelSystemSchema.execute(query, context: context).to_h
    end

    it 'returns all rooms when no filters or sorting are applied' do
      query =
        %(query {
        allRooms {
          id
          roomClass
          price
        }
      })

      result = execute_query(query)
      expect(result.dig('data', 'allRooms')&.length).to eq(Room.count)
    end

    it 'returns filtered rooms based on room class' do
      query_with_filter = %(query {
        allRooms(filter: { roomClass: Standard }) {
          id
          roomClass
          price
        }
      })

      filtered_result = execute_query(query_with_filter)
      puts filtered_result
      puts Room.where(room_class: 'Luxury')
      expect(filtered_result.dig('data', 'allRooms')&.length).to eq(Room.where(room_class: 'Standard').count)
      expect(filtered_result.dig('data', 'allRooms')[0]['roomClass']).to eq('Standard')
    end

    it 'returns filtered rooms based on price range' do
      query_with_filter = %(query {
        allRooms(filter: { minPrice: 150, maxPrice: 200 }) {
          id
          roomClass
          price
        }
      })

      filtered_result = execute_query(query_with_filter)
      puts filtered_result
      expect(filtered_result.dig('data', 'allRooms')&.length).to eq(2)
      expect(filtered_result.dig('data', 'allRooms')[0]['price']).to be >= 150
      expect(filtered_result.dig('data', 'allRooms')[1]['price']).to be <= 200
    end

    it 'returns rooms sorted by price in ascending order' do
      query_with_sort = %(query {
        allRooms(sort: price_ASC) {
          id
          roomClass
          price
        }
      })

      sorted_result = execute_query(query_with_sort)
      expect(sorted_result.dig('data', 'allRooms')&.length).to eq(Room.count)
      expect(sorted_result.dig('data', 'allRooms').map { |room| room['price'] }).to eq([100, 150, 200])
    end

    it 'returns rooms sorted by room class in descending order' do
      query_with_sort = %(query {
        allRooms(sort: room_class_DESC) {
          id
          roomClass
          price
        }
      })

      sorted_result = execute_query(query_with_sort)

      expect(sorted_result.dig('data', 'allRooms')&.length).to eq(Room.count)
      expect(sorted_result.dig('data', 'allRooms').map { |room| room['roomClass'] }).to eq(%w[Luxury Standard Economy])
    end
  end
end
