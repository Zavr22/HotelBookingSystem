# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :bigint           not null, primary key
#  free_count  :integer
#  name        :string
#  price       :float
#  room_class  :string
#  room_number :integer
#  total_count :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
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
