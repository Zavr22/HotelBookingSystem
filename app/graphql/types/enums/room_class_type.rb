# frozen_string_literal: true

module Types::Enums
  class RoomClassType < Types::BaseEnum
    description "Room class enum"

    value "LOW", value: "low", description: "the lowest class."
    value "MEDIUM", value: "medium", description: "medium class"
    value "LUX", value: "lux", description: "the highest class"
  end
end
