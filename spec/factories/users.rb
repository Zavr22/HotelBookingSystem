# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    login { 'MyString' }
    password { 'MyString' }
    trait :admin do
      role { 'admin' }
    end
  end
end
