# frozen_string_literal: true
module GraphQL
  module Relay
    class GlobalIdResolve
      def initialize(type:)
        @type = type
      end

      def call(obj, args, ctx)
        if obj.is_a?(GraphQL::Schema::Object)
          obj = obj.object
        end
        ctx.query.schema.id_from_object(obj, @type, ctx)
      end
    end
  end
end
