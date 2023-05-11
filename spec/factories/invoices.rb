# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    sequence(:id) { |n| n }
    user
    request
    room
    amount_due { rand(100.0..1000.0).round(2) }
    paid { [true, false].sample }
  end
end
