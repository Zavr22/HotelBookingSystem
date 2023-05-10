# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    room_class { %w[Economy Standard Luxury].sample }
    room_number { rand(100..999) }
    free { [true, false].sample }
  end
end