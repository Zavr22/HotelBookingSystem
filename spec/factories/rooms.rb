# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :bigint           not null, primary key
#  free        :boolean
#  room_class  :string
#  room_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :room do
    room_class { %w[Economy Standard Luxury].sample }
    room_number { rand(100..999) }
    free { [true, false].sample }
  end
end
