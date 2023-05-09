# frozen_string_literal: true

require 'search_object'
require 'search_object/plugin/graphql'

class Resolvers::RequestsSearch

  include SearchObject.module(:graphql)

  scope { Request.all }

  type types[Types::RequestType]
  

end

