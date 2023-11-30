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
class Room < ApplicationRecord
  has_one :invoice
  belongs_to :request, optional: true
end
