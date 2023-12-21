# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'

# class Invoice search contains filter for invoices
module Resolvers
  class InvoiceSearch
    include SearchObject.module(:graphql)
    include Sortable
    class << self
      def validate_directive_argument(arg_defn, value)
        # empty method body
      end
    end

    scope { Invoice.all }

    type types[Types::InvoiceType]

    # class InvoiceFilter is used to declare argument user_id for filtering
    class InvoiceFilter < ::Types::BaseInputObject
      argument :user_id, Integer, required: false
    end

    # class InvoiceOrderBy is used to declare values for sorting invoices by date
    class InvoiceSortInput < ::Types::BaseInputObject
      argument :created_at, Types::SortDirectionType, required: false
      argument :amount_due, Types::SortDirectionType, required: false
    end

    option :filter, type: InvoiceFilter, with: :apply_filter
    option :sort, type: InvoiceSortInput, with: :apply_sort

    def apply_sort(scope, value)
      sort_values = value.to_h
      puts sort_values
      sort_mappings = {
        created_at: {
          'ASC' => :apply_order_by_with_created_at_asc,
          'DESC' => :apply_order_by_with_created_at_desc
        },
        amount_due: {
          'ASC' => :apply_order_by_with_amount_due_asc,
          'DESC' => :apply_order_by_with_amount_due_desc
        }
      }

      super(scope, sort_values, sort_mappings)
    end

    def apply_filter(scope, value)
      branches = normalize_filters(value).reduce { |a, b| a.or(b) }
      scope.merge branches
    end

    def normalize_filters(value, branches = [])
      scope = Invoice.all
      scope = scope.where(user_id: value[:user_id]) if value[:user_id]

      branches << scope

      branches
    end

    def apply_order_by_with_created_at_asc(scope)
      scope.order('created_at ASC')
    end

    def apply_order_by_with_created_at_desc(scope)
      scope.order('created_at DESC')
    end

    def fetch_results
      if InvoicePolicy.new(@context[:current_user], nil).user_is_admin?
        super
      elsif InvoicePolicy.new(@context[:current_user], nil).user_is_regular?
        super.where(user_id: context[:current_user]&.id)
      else
        raise GraphQL::ExecutionError, 'You need to authenticate to perform this action'
      end
    end
  end
end
