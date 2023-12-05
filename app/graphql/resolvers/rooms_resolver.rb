# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'

class Resolvers::RoomsResolver
  include SearchObject.module(:graphql)

  class << self
    def validate_directive_argument(arg_defn, value)
      # empty method body
    end
  end

  scope { Room.free }

  type types[Types::RoomType]

  # class RoomsFilter defines arguments for filtering rooms
  class RoomsFilter < ::Types::BaseInputObject
    argument :room_class, String, required: false
  end

  # class RoomPriceSort defines values for sorting rooms
  class RoomPriceSort < ::Types::BaseEnum
    value 'price_ASC'
    value 'price_DESC'
  end

  option :filter, type: RoomsFilter, with: :apply_filter
  option :sort, type: RoomPriceSort, default: 'price_ASC'

  def apply_filter(scope, value)
    branches = normalize_filters(value).reduce { |a, b| a.or(b) }
    scope.merge branches
  end

  def normalize_filters(value, branches = [])
    scope = Room.all
    scope = scope.where(room_class: value[:room_class]) if value[:room_class]

    branches << scope

    branches
  end

  def apply_sort_with_price_asc(scope)
    scope.order('price ASC')
  end

  def apply_sort_with_price_desc(scope)
    scope.order('price DESC')
  end

  def fetch_results
    if RoomPolicy.new(@context[:current_user], nil).user_is_admin?
      Room.all
    elsif RoomPolicy.new(@context[:current_user], nil).user_is_regular?
      super
    else
      raise GraphQL::ExecutionError, 'You need to authenticate to perform this action'
    end
  end
end
