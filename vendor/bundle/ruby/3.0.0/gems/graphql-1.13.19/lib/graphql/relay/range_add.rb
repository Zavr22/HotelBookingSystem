# frozen_string_literal: true
module GraphQL
  module Relay
    # This provides some isolation from `GraphQL::Relay` internals.
    #
    # Given a list of items and a new item, it will provide a connection and an edge.
    #
    # The connection doesn't receive outside arguments, so the list of items
    # should be ordered and paginated before providing it here.
    #
    # @example Adding a comment to list of comments
    #   post = Post.find(args[:post_id])
    #   comments = post.comments
    #   new_comment = comments.build(body: args[:body])
    #   new_comment.save!
    #
    #   range_add = GraphQL::Relay::RangeAdd.new(
    #     parent: post,
    #     collection: comments,
    #     item: new_comment,
    #     context: context,
    #   )
    #
    #   response = {
    #     post: post,
    #     comments_connection: range_add.connection,
    #     new_comment_edge: range_add.edge,
    #   }
    class RangeAdd
      attr_reader :edge, :connection, :parent

      # @param collection [Object] The list of items to wrap in a connection
      # @param item [Object] The newly-added item (will be wrapped in `edge_class`)
      # @param parent [Object] The owner of `collection`, will be passed to the connection if provided
      # @param context [GraphQL::Query::Context] The surrounding `ctx`, will be passed to the connection if provided (this is required for cursor encoders)
      # @param edge_class [Class] The class to wrap `item` with (defaults to the connection's edge class)
      def initialize(collection:, item:, parent: nil, context: nil, edge_class: nil)
        if context.nil?
          caller_loc = caller(2, 1).first
          GraphQL::Deprecation.warn("`context: ...` will be required by `RangeAdd.new` in GraphQL-Ruby 2.0. Add `context: context` to the call at #{caller_loc}.")
        end
        if context && context.schema.new_connections?
          conn_class = context.schema.connections.wrapper_for(collection)
          # The rest will be added by ConnectionExtension
          @connection = conn_class.new(collection, parent: parent, context: context, edge_class: edge_class)
          # Check if this connection supports it, to support old versions of GraphQL-Pro
          @edge = if @connection.respond_to?(:range_add_edge)
            @connection.range_add_edge(item)
          else
            @connection.edge_class.new(item, @connection)
          end
        else
          connection_class = BaseConnection.connection_for_nodes(collection)
          @connection = connection_class.new(collection, {}, parent: parent, context: context)
          edge_class ||= Relay::Edge
          @edge = edge_class.new(item, @connection)
        end

        @parent = parent
      end
    end
  end
end
