# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'
require 'graphql/query_resolver'

module Resolvers
  class RoomsSearch

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
      scope = apply_sort_with_room_class_asc(scope) if value[:room_class] == 'ASC'
      scope = apply_sort_with_room_class_desc(scope) if value[:room_class] == 'DESC'
      scope = scope.order(price: value[:price]) if value[:price].present?
      scope
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

    def apply_sort_with_price_asc(scope)
      scope.order('price ASC')
    end

    def apply_sort_with_price_desc(scope)
      scope.order('price DESC')
    end

    def apply_sort_with_room_class_asc(scope)
      scope.order(Arel.sql('CASE WHEN room_class = \'Economy\' THEN 1 WHEN room_class = \'Standard\' THEN 2 WHEN room_class = \'Luxury\' THEN 3 ELSE 4 END ASC'))
    end

    def apply_sort_with_room_class_desc(scope)
      scope.order(Arel.sql('CASE WHEN room_class = \'Economy\' THEN 1 WHEN room_class = \'Standard\' THEN 2 WHEN room_class = \'Luxury\' THEN 3 ELSE 4 END DESC'))
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
