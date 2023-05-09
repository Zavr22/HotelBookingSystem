require 'search_object'
require 'search_object/plugin/graphql'
require_relative '../types/query_type'

require 'graphql/query_resolver'

class Resolvers::RequestsSearch

  class << self
    def validate_directive_argument(arg_defn, value)
      # empty method body
    end
  end

  include SearchObject.module(:graphql)

  scope { Request.all }
  type types[Types::RequestType]

  class RequestFilter < ::Types::BaseInputObject
    argument :user_id, Integer, required: false
  end

  option :filter, type: RequestFilter, with: :apply_filter

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
    role = User.where(id: context[:current_user]&.id).select("role")
    if role == "admin"
      super
    elsif role == "user"
      raise GraphQL::ExecutionError, "You need to authenticate to perform this action"

    end
  end
end
