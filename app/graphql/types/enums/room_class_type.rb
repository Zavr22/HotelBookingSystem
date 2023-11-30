# frozen_string_literal: true

module Types::Enums
  class RoomClassType < Types::BaseEnum
    description 'Room class enum'

    value 'ECONOMY', value: 'Economy', description: 'the lowest class.'
    value 'STANDARD', value: 'Standard', description: 'medium class'
    value 'LUXURY', value: 'Luxury', description: 'the highest class'
  end
end
