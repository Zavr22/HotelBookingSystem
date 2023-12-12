# frozen_string_literal: true

module Types::Enums
  class RoomClassType < Types::BaseEnum
    description 'Room class enum'

    value 'Economy', value: 'Economy', description: 'the lowest class.'
    value 'Standard', value: 'Standard', description: 'medium class'
    value 'Luxury', value: 'Luxury', description: 'the highest class'
  end
end
