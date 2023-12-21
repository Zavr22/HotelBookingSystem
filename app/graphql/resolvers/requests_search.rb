# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'
require 'graphql/query_resolver'

# class RequestSearch contains methods to filter requests
module Resolvers
  class RequestsSearch
    include Sortable
    class << self
      def validate_directive_argument(arg_defn, value)
        # empty method body
      end
    end

    include SearchObject.module(:graphql)

    scope { Request.all }
    type types[Types::RequestType]

  # class RequestFilter is used for declare argument user_id for filtering
    class RequestFilter < ::Types::BaseInputObject
      argument :user_id, Integer, required: false
    end

    option :filter, type: RequestFilter, with: :apply_filter

    class RequestSortInput < Types::BaseInputObject
      argument :created_at, Types::SortDirectionType, required: false
    end

    option :sort, type: RequestSortInput, with: :apply_sort

    def apply_sort(scope, value)
      sort_values = value.to_h
      puts sort_values
      sort_mappings = {
        created_at: {
          'ASC' => :apply_order_by_with_created_at_asc,
          'DESC' => :apply_order_by_with_created_at_desc
        }
      }

      super(scope, sort_values, sort_mappings)
    end
    def apply_filter(scope, value)
      branches = normalize_filters(value).reduce { |a, b| a.or(b) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = Request.all
      scope = scope.where(user_id: value[:user_id]) if value[:user_id]
      branches << scope
      branches
    end

    def fetch_results
      if RequestPolicy.new(@context[:current_user], nil).user_is_admin?
        super
      else
        raise GraphQL::ExecutionError, 'You need to be admin to perform this action'
      end
    end
  end
end
