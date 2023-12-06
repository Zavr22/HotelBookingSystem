# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe RoomsSearch do
    describe 'apply_filter' do
      let!(:economy_room) { FactoryBot.create(:room, room_class: 'Economy', price: 50, free_count: 5) }
      let!(:standard_room) { FactoryBot.create(:room, room_class: 'Standard', price: 100, free_count: 3) }
      let!(:luxury_room) { FactoryBot.create(:room, room_class: 'Luxury', price: 200, free_count: 2) }

      it 'filters rooms by room_class, min_price, and max_price' do
        resolver = RoomsSearch.new
        value = { room_class: 'Standard', min_price: 80, max_price: 120 }
        result = resolver.apply_filter(Room.all, value)

        expect(result).to eq([standard_room])
      end
    end

    describe 'fetch_results' do
      let(:admin_user) { FactoryBot.create(:user, role: 'admin') }
      let(:regular_user) { FactoryBot.create(:user) }

      before do
        FactoryBot.create_list(:room, 5)
      end

      context 'when the current user is an admin' do
        it 'returns all rooms' do
          resolver = RoomsSearch.new
          resolver.instance_variable_set(:@context, { current_user: admin_user })

          allow(RoomPolicy.new(admin_user, nil)).to receive(:user_is_admin?).and_return(true)
          allow(RoomPolicy.new(admin_user, nil)).to receive(:user_is_regular?).and_return(false)

          result = resolver.fetch_results

          expect(result).to eq(Room.all)
        end
      end

      context 'when the current user is a regular user' do
        it 'raises an execution error' do
          resolver = RoomsSearch.new
          resolver.instance_variable_set(:@context, { current_user: regular_user })

          allow(RoomPolicy.new(regular_user, nil)).to receive(:user_is_admin?).and_return(false)
          allow(RoomPolicy.new(regular_user, nil)).to receive(:user_is_regular?).and_return(true)

          expect { resolver.fetch_results }.to raise_error(GraphQL::ExecutionError, 'You need to authenticate to perform this action')
        end
      end
    end

    describe 'apply_sort_with_price_asc' do
      let!(:economy_room) { FactoryBot.create(:room, room_class: 'Economy', price: 50, free_count: 5) }
      let!(:standard_room) { FactoryBot.create(:room, room_class: 'Standard', price: 100, free_count: 3) }
      let!(:luxury_room) { FactoryBot.create(:room, room_class: 'Luxury', price: 200, free_count: 2) }

      it 'sorts rooms by price in ascending order' do
        resolver = RoomsSearch.new
        result = resolver.apply_sort_with_price_asc(Room.all)

        expect(result).to eq([economy_room, standard_room, luxury_room])
      end
    end

    describe 'apply_sort_with_price_desc' do
      let!(:economy_room) { FactoryBot.create(:room, room_class: 'Economy', price: 50, free_count: 5) }
      let!(:standard_room) { FactoryBot.create(:room, room_class: 'Standard', price: 100, free_count: 3) }
      let!(:luxury_room) { FactoryBot.create(:room, room_class: 'Luxury', price: 200, free_count: 2) }

      it 'sorts rooms by price in descending order' do
        resolver = RoomsSearch.new
        result = resolver.apply_sort_with_price_desc(Room.all)

        expect(result).to eq([luxury_room, standard_room, economy_room])
      end
    end

    describe 'apply_sort_with_room_class_asc' do
      let!(:economy_room) { FactoryBot.create(:room, room_class: 'Economy', price: 50, free_count: 5) }
      let!(:standard_room) { FactoryBot.create(:room, room_class: 'Standard', price: 100, free_count: 3) }
      let!(:luxury_room) { FactoryBot.create(:room, room_class: 'Luxury', price: 200, free_count: 2) }

      it 'sorts rooms by room_class in ascending order' do
        resolver = RoomsSearch.new
        result = resolver.apply_sort_with_room_class_asc(Room.all)

        expect(result).to eq([economy_room, standard_room, luxury_room])
      end
    end

    describe 'apply_sort_with_room_class_desc' do
      let!(:economy_room) { FactoryBot.create(:room, room_class: 'Economy', price: 50, free_count: 5) }
      let!(:standard_room) { FactoryBot.create(:room, room_class: 'Standard', price: 100, free_count: 3) }
      let!(:luxury_room) { FactoryBot.create(:room, room_class: 'Luxury', price: 200, free_count: 2) }

      it 'sorts rooms by room_class in descending order' do
        resolver = RoomsSearch.new
        result = resolver.apply_sort_with_room_class_desc(Room.all)

        expect(result).to eq([luxury_room, standard_room, economy_room])
      end
    end
  end
end
