# frozen_string_literal: true

# == Schema Information
#
# Table name: requests
#
#  id             :bigint           not null, primary key
#  apart_class    :string
#  capacity       :integer
#  check_in_date  :date
#  check_out_date :date
#  duration       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  room_id        :bigint
#  user_id        :bigint           not null
#
# Indexes
#
#  index_requests_on_room_id  (room_id)
#  index_requests_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (room_id => rooms.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :request do
    user
    capacity { rand(1..5) }
    apart_class { %w[Economy Standard Luxury].sample }
    duration { rand(1..10) }
  end
end



