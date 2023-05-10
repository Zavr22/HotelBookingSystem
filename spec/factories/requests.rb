# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    user
    capacity { rand(1..5) }
    apart_class { %w[Economy Standard Luxury].sample }
    duration { rand(1..10) }
  end
end



