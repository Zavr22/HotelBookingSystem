# frozen_string_literal: true

module Types
  # class RequestType
  class RequestType < Types::BaseObject
    implements Interfaces::SomeInterface
    field :user_id, Integer, null: false
    field :capacity, Integer
    field :apart_class, String
    field :duration, Integer
  end
end
