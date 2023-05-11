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

FactoryBot.define do
  factory :invoice1, parent: :invoice do
    created_at { 3.hours.ago } # или другое корректное значение created_at для invoice1
  end
end

# Пример фабрики invoice2
FactoryBot.define do
  factory :invoice2, parent: :invoice do
    created_at { 1.hour.ago } # или другое корректное значение created_at для invoice2
  end
end

# Пример фабрики invoice3
FactoryBot.define do
  factory :invoice3, parent: :invoice do
    created_at { 2.hours.ago } # или другое корректное значение created_at для invoice3
  end
end

