# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'free scope' do
    it 'returns rooms with free_count greater than 0' do
      free_room = FactoryBot.create(:room, free_count: 1)
      booked_room = FactoryBot.create(:room, free_count: 0)

      expect(Room.free).to include(free_room)
      expect(Room.free).not_to include(booked_room)
    end
  end
end
