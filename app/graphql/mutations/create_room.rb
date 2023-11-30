# frozen_string_literal: true

module Mutations
  # class CreateRoom contains method which creates room
  class CreateRoom < BaseMutation
    null true

    argument :room_input, Types::RoomInput, required: false

    type Types::RoomType

    def resolve(room_input: nil)
      return unless room_input

      unless RoomPolicy.new(@context[:current_user], nil).user_is_authenticated?
        raise GraphQL::ExecutionError, 'You need to authenticate to perform this action'
      end
      unless RoomPolicy.new(@context[:current_user], nil).user_is_admin?
        raise GraphQL::ExecutionError, 'You have to be admin'
      end

      Room.create!(
        name: room_input[:name],
        room_class: room_input[:room_class],
        room_number: room_input[:room_number],
        total_count: room_input[:total_count],
        free_count: room_input[:free_count],
        price: room_input[:price]
      )
    end
  end
end
