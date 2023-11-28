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
class Room < ApplicationRecord
  has_one :invoice
end
