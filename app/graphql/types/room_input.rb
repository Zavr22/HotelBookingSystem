# frozen_string_literal: true

module Types
  # class RoomInput
  class RoomInput < BaseInputObject
    graphql_name 'ROOM_INPUT'

    argument :name, String, required: true
    argument :room_class, Enums::RoomClassType, required: true
    argument :room_number, Integer, required: true
    argument :total_count, Integer, required: true
    argument :free_count, Integer, required: true
    argument :price, Float, required: true
    argument :image, ApolloUploadServer::Upload, required: false
  end
end
