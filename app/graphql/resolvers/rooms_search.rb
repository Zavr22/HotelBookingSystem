# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'
require 'graphql/query_resolver'

module Resolvers
  class RoomsSearch
    include Sortable

    class << self
      def validate_directive_argument(arg_defn, value)
        # empty method body
      end
    end

    include SearchObject.module(:graphql)

    scope { Room.all }

    type types[Types::RoomType]

    # class RoomsFilter defines arguments for filtering rooms
    class RoomsFilter < ::Types::BaseInputObject
      argument :room_class, Types::Enums::RoomClassType, required: false
      argument :min_price, Float, required: false
      argument :max_price, Float, required: false
    end

    option :filter, type: RoomsFilter, with: :apply_filter

    # class RoomSort defines values for sorting rooms
    class RoomSortInput < Types::BaseInputObject
      argument :room_class, Types::SortDirectionType, required: false
      argument :price, Types::SortDirectionType, required: false
    end

    option :sort, type: RoomSortInput, with: :apply_sort

    def apply_sort(scope, value)
      sort_values = value.to_h

      sort_mappings = {
        room_class: {
          'ASC' => :apply_sort_with_room_class_asc,
          'DESC' => :apply_sort_with_room_class_desc
        },
        price: {
          'ASC' => :apply_sort_with_price_asc,
          'DESC' => :apply_sort_with_price_desc
        }
      }

      super(scope, sort_values, sort_mappings)
    end

    def apply_filter(scope, value)
      branches = normalize_filters(value).reduce { |a, b| a.and(b) }
      scope.merge branches
    end

    def normalize_filters(value, branches = [])
      scope = Room.free
      scope = scope.where(room_class: value[:room_class].to_s) if value[:room_class]
      scope = scope.where(price: value[:min_price]..(value[:max_price] || Float::INFINITY))

      branches << scope

      branches
    end

    def fetch_results
      if RoomPolicy.new(@context[:current_user], nil).user_is_admin?
        super
      elsif RoomPolicy.new(@context[:current_user], nil).user_is_regular?
        super.free
      else
        raise GraphQL::ExecutionError, 'You need to authenticate to perform this action'
      end
    end
  end
end
