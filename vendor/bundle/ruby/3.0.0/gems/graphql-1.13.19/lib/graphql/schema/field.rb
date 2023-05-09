# frozen_string_literal: true
require "graphql/schema/field/connection_extension"
require "graphql/schema/field/scope_extension"

module GraphQL
  class Schema
    class Field
      include GraphQL::Schema::Member::CachedGraphQLDefinition
      include GraphQL::Schema::Member::AcceptsDefinition
      include GraphQL::Schema::Member::HasArguments
      include GraphQL::Schema::Member::HasAstNode
      include GraphQL::Schema::Member::HasPath
      include GraphQL::Schema::Member::HasValidators
      extend GraphQL::Schema::FindInheritedValue
      include GraphQL::Schema::FindInheritedValue::EmptyObjects
      include GraphQL::Schema::Member::HasDirectives
      include GraphQL::Schema::Member::HasDeprecationReason

      class FieldImplementationFailed < GraphQL::Error; end

      # @return [String] the GraphQL name for this field, camelized unless `camelize: false` is provided
      attr_reader :name
      alias :graphql_name :name

      attr_writer :description

      # @return [Symbol] Method or hash key on the underlying object to look up
      attr_reader :method_sym

      # @return [String] Method or hash key on the underlying object to look up
      attr_reader :method_str

      # @return [Symbol] The method on the type to look up
      attr_reader :resolver_method

      # @return [Class] The thing this field was defined on (type, mutation, resolver)
      attr_accessor :owner

      # @return [Class] The GraphQL type this field belongs to. (For fields defined on mutations, it's the payload type)
      def owner_type
        @owner_type ||= if owner.nil?
          raise GraphQL::InvariantError, "Field #{original_name.inspect} (graphql name: #{graphql_name.inspect}) has no owner, but all fields should have an owner. How did this happen?!"
        elsif owner < GraphQL::Schema::Mutation
          owner.payload_type
        else
          owner
        end
      end

      # @return [Symbol] the original name of the field, passed in by the user
      attr_reader :original_name

      # @return [Class, nil] The {Schema::Resolver} this field was derived from, if there is one
      def resolver
        @resolver_class
      end

      # @return [Boolean] Is this field a predefined introspection field?
      def introspection?
        @introspection
      end

      def inspect
        "#<#{self.class} #{path}#{all_argument_definitions.any? ? "(...)" : ""}: #{type.to_type_signature}>"
      end

      alias :mutation :resolver

      # @return [Boolean] Apply tracing to this field? (Default: skip scalars, this is the override value)
      attr_reader :trace

      # @return [String, nil]
      attr_accessor :subscription_scope

      # Create a field instance from a list of arguments, keyword arguments, and a block.
      #
      # This method implements prioritization between the `resolver` or `mutation` defaults
      # and the local overrides via other keywords.
      #
      # It also normalizes positional arguments into keywords for {Schema::Field#initialize}.
      # @param resolver [Class] A {GraphQL::Schema::Resolver} class to use for field configuration
      # @param mutation [Class] A {GraphQL::Schema::Mutation} class to use for field configuration
      # @param subscription [Class] A {GraphQL::Schema::Subscription} class to use for field configuration
      # @return [GraphQL::Schema:Field] an instance of `self
      # @see {.initialize} for other options
      def self.from_options(name = nil, type = nil, desc = nil, resolver: nil, mutation: nil, subscription: nil,**kwargs, &block)
        if kwargs[:field]
          if kwargs[:field].is_a?(GraphQL::Field) && kwargs[:field] == GraphQL::Types::Relay::NodeField.graphql_definition
            GraphQL::Deprecation.warn("Legacy-style `GraphQL::Relay::Node.field` is being added to a class-based type. See `GraphQL::Types::Relay::NodeField` for a replacement.")
            return GraphQL::Types::Relay::NodeField
          elsif kwargs[:field].is_a?(GraphQL::Field) && kwargs[:field] == GraphQL::Types::Relay::NodesField.graphql_definition
            GraphQL::Deprecation.warn("Legacy-style `GraphQL::Relay::Node.plural_field` is being added to a class-based type. See `GraphQL::Types::Relay::NodesField` for a replacement.")
            return GraphQL::Types::Relay::NodesField
          end
        end

        if (parent_config = resolver || mutation || subscription)
          # Get the parent config, merge in local overrides
          kwargs = parent_config.field_options.merge(kwargs)
          # Add a reference to that parent class
          kwargs[:resolver_class] = parent_config
        end

        if name
          kwargs[:name] = name
        end

        if !type.nil?
          if type.is_a?(GraphQL::Field)
            raise ArgumentError, "A GraphQL::Field was passed as the second argument, use the `field:` keyword for this instead."
          end
          if desc
            if kwargs[:description]
              raise ArgumentError, "Provide description as a positional argument or `description:` keyword, but not both (#{desc.inspect}, #{kwargs[:description].inspect})"
            end

            kwargs[:description] = desc
            kwargs[:type] = type
          elsif (kwargs[:field] || kwargs[:function] || resolver || mutation) && type.is_a?(String)
            # The return type should be copied from `field` or `function`, and the second positional argument is the description
            kwargs[:description] = type
          else
            kwargs[:type] = type
          end
          if type.is_a?(Class) && type < GraphQL::Schema::Mutation
            raise ArgumentError, "Use `field #{name.inspect}, mutation: Mutation, ...` to provide a mutation to this field instead"
          end
        end
        new(**kwargs, &block)
      end

      # Can be set with `connection: true|false` or inferred from a type name ending in `*Connection`
      # @return [Boolean] if true, this field will be wrapped with Relay connection behavior
      def connection?
        if @connection.nil?
          # Provide default based on type name
          return_type_name = if (contains_type = @field || @function)
            Member::BuildType.to_type_name(contains_type.type)
          elsif @return_type_expr
            Member::BuildType.to_type_name(@return_type_expr)
          else
            # As a last ditch, try to force loading the return type:
            type.unwrap.name
          end
          @connection = return_type_name.end_with?("Connection")
        else
          @connection
        end
      end

      # @return [Boolean] if true, the return type's `.scope_items` method will be applied to this field's return value
      def scoped?
        if !@scope.nil?
          # The default was overridden
          @scope
        else
          @return_type_expr && (@return_type_expr.is_a?(Array) || (@return_type_expr.is_a?(String) && @return_type_expr.include?("[")) || connection?)
        end
      end

      # This extension is applied to fields when {#connection?} is true.
      #
      # You can override it in your base field definition.
      # @return [Class] A {FieldExtension} subclass for implementing pagination behavior.
      # @example Configuring a custom extension
      #   class Types::BaseField < GraphQL::Schema::Field
      #     connection_extension(MyCustomExtension)
      #   end
      def self.connection_extension(new_extension_class = nil)
        if new_extension_class
          @connection_extension = new_extension_class
        else
          @connection_extension ||= find_inherited_value(:connection_extension, ConnectionExtension)
        end
      end

      # @return Boolean
      attr_reader :relay_node_field
      # @return Boolean
      attr_reader :relay_nodes_field

      # @return [Boolean] Should we warn if this field's name conflicts with a built-in method?
      def method_conflict_warning?
        @method_conflict_warning
      end

      # @param name [Symbol] The underscore-cased version of this field name (will be camelized for the GraphQL API)
      # @param type [Class, GraphQL::BaseType, Array] The return type of this field
      # @param owner [Class] The type that this field belongs to
      # @param null [Boolean] `true` if this field may return `null`, `false` if it is never `null`
      # @param description [String] Field description
      # @param deprecation_reason [String] If present, the field is marked "deprecated" with this message
      # @param method [Symbol] The method to call on the underlying object to resolve this field (defaults to `name`)
      # @param hash_key [String, Symbol] The hash key to lookup on the underlying object (if its a Hash) to resolve this field (defaults to `name` or `name.to_s`)
      # @param dig [Array<String, Symbol>] The nested hash keys to lookup on the underlying hash to resolve this field using dig
      # @param resolver_method [Symbol] The method on the type to call to resolve this field (defaults to `name`)
      # @param connection [Boolean] `true` if this field should get automagic connection behavior; default is to infer by `*Connection` in the return type name
      # @param connection_extension [Class] The extension to add, to implement connections. If `nil`, no extension is added.
      # @param max_page_size [Integer, nil] For connections, the maximum number of items to return from this field, or `nil` to allow unlimited results.
      # @param introspection [Boolean] If true, this field will be marked as `#introspection?` and the name may begin with `__`
      # @param resolve [<#call(obj, args, ctx)>] **deprecated** for compatibility with <1.8.0
      # @param field [GraphQL::Field, GraphQL::Schema::Field] **deprecated** for compatibility with <1.8.0
      # @param function [GraphQL::Function] **deprecated** for compatibility with <1.8.0
      # @param resolver_class [Class] (Private) A {Schema::Resolver} which this field was derived from. Use `resolver:` to create a field with a resolver.
      # @param arguments [{String=>GraphQL::Schema::Argument, Hash}] Arguments for this field (may be added in the block, also)
      # @param camelize [Boolean] If true, the field name will be camelized when building the schema
      # @param complexity [Numeric] When provided, set the complexity for this field
      # @param scope [Boolean] If true, the return type's `.scope_items` method will be called on the return value
      # @param subscription_scope [Symbol, String] A key in `context` which will be used to scope subscription payloads
      # @param extensions [Array<Class, Hash<Class => Object>>] Named extensions to apply to this field (see also {#extension})
      # @param directives [Hash{Class => Hash}] Directives to apply to this field
      # @param trace [Boolean] If true, a {GraphQL::Tracing} tracer will measure this scalar field
      # @param broadcastable [Boolean] Whether or not this field can be distributed in subscription broadcasts
      # @param ast_node [Language::Nodes::FieldDefinition, nil] If this schema was parsed from definition, this AST node defined the field
      # @param method_conflict_warning [Boolean] If false, skip the warning if this field's method conflicts with a built-in method
      # @param validates [Array<Hash>] Configurations for validating this field
      # @param legacy_edge_class [Class, nil] (DEPRECATED) If present, pass this along to the legacy field definition
      def initialize(type: nil, name: nil, owner: nil, null: true, field: nil, function: nil, description: nil, deprecation_reason: nil, method: nil, hash_key: nil, dig: nil, resolver_method: nil, resolve: nil, connection: nil, max_page_size: :not_given, scope: nil, introspection: false, camelize: true, trace: nil, complexity: 1, ast_node: nil, extras: EMPTY_ARRAY, extensions: EMPTY_ARRAY, connection_extension: self.class.connection_extension, resolver_class: nil, subscription_scope: nil, relay_node_field: false, relay_nodes_field: false, method_conflict_warning: true, broadcastable: nil, arguments: EMPTY_HASH, directives: EMPTY_HASH, validates: EMPTY_ARRAY, legacy_edge_class: nil, &definition_block)
        if name.nil?
          raise ArgumentError, "missing first `name` argument or keyword `name:`"
        end
        if !(field || function || resolver_class)
          if type.nil?
            raise ArgumentError, "missing second `type` argument or keyword `type:`"
          end
        end
        if (field || function || resolve) && extras.any?
          raise ArgumentError, "keyword `extras:` may only be used with method-based resolve and class-based field such as mutation class, please remove `field:`, `function:` or `resolve:`"
        end
        @original_name = name
        name_s = -name.to_s

        @underscored_name = -Member::BuildType.underscore(name_s)
        @name = -(camelize ? Member::BuildType.camelize(name_s) : name_s)
        @description = description
        if field.is_a?(GraphQL::Schema::Field)
          raise ArgumentError, "Instead of passing a field as `field:`, use `add_field(field)` to add an already-defined field."
        else
          @field = field
        end
        @function = function
        @resolve = resolve
        self.deprecation_reason = deprecation_reason

        if method && hash_key && dig
          raise ArgumentError, "Provide `method:`, `hash_key:` _or_ `dig:`, not multiple. (called with: `method: #{method.inspect}, hash_key: #{hash_key.inspect}, dig: #{dig.inspect}`)"
        end

        if resolver_method
          if method
            raise ArgumentError, "Provide `method:` _or_ `resolver_method:`, not both. (called with: `method: #{method.inspect}, resolver_method: #{resolver_method.inspect}`)"
          end

          if hash_key || dig
            raise ArgumentError, "Provide `hash_key:`, `dig:`, _or_ `resolver_method:`, not multiple. (called with: `hash_key: #{hash_key.inspect}, dig: #{dig.inspect}, resolver_method: #{resolver_method.inspect}`)"
          end
        end

        # TODO: I think non-string/symbol hash keys are wrongly normalized (eg `1` will not work)
        method_name = method || hash_key || name_s
        @dig_keys = dig
        if hash_key
          @hash_key = hash_key
        end

        resolver_method ||= name_s.to_sym

        @method_str = -method_name.to_s
        @method_sym = method_name.to_sym
        @resolver_method = resolver_method
        @complexity = complexity
        @return_type_expr = type
        @return_type_null = null
        @connection = connection
        @has_max_page_size = max_page_size != :not_given
        @max_page_size = max_page_size == :not_given ? nil : max_page_size
        @introspection = introspection
        @extras = extras
        @broadcastable = broadcastable
        @resolver_class = resolver_class
        @scope = scope
        @trace = trace
        @relay_node_field = relay_node_field
        @relay_nodes_field = relay_nodes_field
        @ast_node = ast_node
        @method_conflict_warning = method_conflict_warning
        @legacy_edge_class = legacy_edge_class

        arguments.each do |name, arg|
          case arg
          when Hash
            argument(name: name, **arg)
          when GraphQL::Schema::Argument
            add_argument(arg)
          when Array
            arg.each { |a| add_argument(a) }
          else
            raise ArgumentError, "Unexpected argument config (#{arg.class}): #{arg.inspect}"
          end
        end

        @owner = owner
        @subscription_scope = subscription_scope

        @extensions = EMPTY_ARRAY
        @call_after_define = false
        # This should run before connection extension,
        # but should it run after the definition block?
        if scoped?
          self.extension(ScopeExtension)
        end

        # The problem with putting this after the definition_block
        # is that it would override arguments
        if connection? && connection_extension
          self.extension(connection_extension)
        end

        # Do this last so we have as much context as possible when initializing them:
        if extensions.any?
          self.extensions(extensions)
        end

        if directives.any?
          directives.each do |(dir_class, options)|
            self.directive(dir_class, **options)
          end
        end

        self.validates(validates)

        if definition_block
          if definition_block.arity == 1
            yield self
          else
            instance_eval(&definition_block)
          end
        end

        self.extensions.each(&:after_define_apply)
        @call_after_define = true
      end

      # If true, subscription updates with this field can be shared between viewers
      # @return [Boolean, nil]
      # @see GraphQL::Subscriptions::BroadcastAnalyzer
      def broadcastable?
        @broadcastable
      end

      # @param text [String]
      # @return [String]
      def description(text = nil)
        if text
          @description = text
        else
          @description
        end
      end

      # Read extension instances from this field,
      # or add new classes/options to be initialized on this field.
      # Extensions are executed in the order they are added.
      #
      # @example adding an extension
      #   extensions([MyExtensionClass])
      #
      # @example adding multiple extensions
      #   extensions([MyExtensionClass, AnotherExtensionClass])
      #
      # @example adding an extension with options
      #   extensions([MyExtensionClass, { AnotherExtensionClass => { filter: true } }])
      #
      # @param extensions [Array<Class, Hash<Class => Hash>>] Add extensions to this field. For hash elements, only the first key/value is used.
      # @return [Array<GraphQL::Schema::FieldExtension>] extensions to apply to this field
      def extensions(new_extensions = nil)
        if new_extensions
          new_extensions.each do |extension_config|
            if extension_config.is_a?(Hash)
              extension_class, options = *extension_config.to_a[0]
              self.extension(extension_class, options)
            else
              self.extension(extension_config)
            end
          end
        end
        @extensions
      end

      # Add `extension` to this field, initialized with `options` if provided.
      #
      # @example adding an extension
      #   extension(MyExtensionClass)
      #
      # @example adding an extension with options
      #   extension(MyExtensionClass, filter: true)
      #
      # @param extension_class [Class] subclass of {Schema::FieldExtension}
      # @param options [Hash] if provided, given as `options:` when initializing `extension`.
      # @return [void]
      def extension(extension_class, options = nil)
        extension_inst = extension_class.new(field: self, options: options)
        if @extensions.frozen?
          @extensions = @extensions.dup
        end
        if @call_after_define
          extension_inst.after_define_apply
        end
        @extensions << extension_inst
        nil
      end

      # Read extras (as symbols) from this field,
      # or add new extras to be opted into by this field's resolver.
      #
      # @param new_extras [Array<Symbol>] Add extras to this field
      # @return [Array<Symbol>]
      def extras(new_extras = nil)
        if new_extras.nil?
          # Read the value
          @extras
        else
          if @extras.frozen?
            @extras = @extras.dup
          end
          # Append to the set of extras on this field
          @extras.concat(new_extras)
        end
      end

      def calculate_complexity(query:, nodes:, child_complexity:)
        if respond_to?(:complexity_for)
          lookahead = GraphQL::Execution::Lookahead.new(query: query, field: self, ast_nodes: nodes, owner_type: owner)
          complexity_for(child_complexity: child_complexity, query: query, lookahead: lookahead)
        elsif connection?
          arguments = query.arguments_for(nodes.first, self)
          max_possible_page_size = nil
          if arguments.respond_to?(:[]) # It might have been an error
            if arguments[:first]
              max_possible_page_size = arguments[:first]
            end

            if arguments[:last] && (max_possible_page_size.nil? || arguments[:last] > max_possible_page_size)
              max_possible_page_size = arguments[:last]
            end
          end

          if max_possible_page_size.nil?
            max_possible_page_size = max_page_size || query.schema.default_max_page_size
          end

          if max_possible_page_size.nil?
            raise GraphQL::Error, "Can't calculate complexity for #{path}, no `first:`, `last:`, `max_page_size` or `default_max_page_size`"
          else
            metadata_complexity = 0
            lookahead = GraphQL::Execution::Lookahead.new(query: query, field: self, ast_nodes: nodes, owner_type: owner)

            if (page_info_lookahead = lookahead.selection(:page_info)).selected?
              metadata_complexity += 1 # pageInfo
              metadata_complexity += page_info_lookahead.selections.size # subfields
            end

            if lookahead.selects?(:total) || lookahead.selects?(:total_count) || lookahead.selects?(:count)
              metadata_complexity += 1
            end

            nodes_edges_complexity = 0
            nodes_edges_complexity += 1 if lookahead.selects?(:edges)
            nodes_edges_complexity += 1 if lookahead.selects?(:nodes)

            # Possible bug: selections on `edges` and `nodes` are _both_ multiplied here. Should they be?
            items_complexity = child_complexity - metadata_complexity - nodes_edges_complexity
            # Add 1 for _this_ field
            1 + (max_possible_page_size * items_complexity) + metadata_complexity + nodes_edges_complexity
          end
        else
          defined_complexity = complexity
          case defined_complexity
          when Proc
            arguments = query.arguments_for(nodes.first, self)
            if arguments.is_a?(GraphQL::ExecutionError)
              return child_complexity
            elsif arguments.respond_to?(:keyword_arguments)
              arguments = arguments.keyword_arguments
            end

            defined_complexity.call(query.context, arguments, child_complexity)
          when Numeric
            defined_complexity + child_complexity
          else
            raise("Invalid complexity: #{defined_complexity.inspect} on #{path} (#{inspect})")
          end
        end
      end

      def complexity(new_complexity = nil)
        case new_complexity
        when Proc
          if new_complexity.parameters.size != 3
            fail(
              "A complexity proc should always accept 3 parameters: ctx, args, child_complexity. "\
              "E.g.: complexity ->(ctx, args, child_complexity) { child_complexity * args[:limit] }"
            )
          else
            @complexity = new_complexity
          end
        when Numeric
          @complexity = new_complexity
        when nil
          @complexity
        else
          raise("Invalid complexity: #{new_complexity.inspect} on #{@name}")
        end
      end

      # @return [Boolean] True if this field's {#max_page_size} should override the schema default.
      def has_max_page_size?
        @has_max_page_size
      end

      # @return [Integer, nil] Applied to connections if {#has_max_page_size?}
      attr_reader :max_page_size

      prepend Schema::Member::CachedGraphQLDefinition::DeprecatedToGraphQL

      # @return [GraphQL::Field]
      def to_graphql
        field_defn = if @field
          @field.dup
        elsif @function
          GraphQL::Function.build_field(@function)
        else
          GraphQL::Field.new
        end

        field_defn.name = @name
        if @return_type_expr
          field_defn.type = -> { type }
        end

        if @description
          field_defn.description = @description
        end

        if self.deprecation_reason
          field_defn.deprecation_reason = self.deprecation_reason
        end

        if @resolver_class
          if @resolver_class < GraphQL::Schema::Mutation
            field_defn.mutation = @resolver_class
          end
          field_defn.metadata[:resolver] = @resolver_class
        end

        if !@trace.nil?
          field_defn.trace = @trace
        end

        if @relay_node_field
          field_defn.relay_node_field = @relay_node_field
        end

        if @relay_nodes_field
          field_defn.relay_nodes_field = @relay_nodes_field
        end

        if @legacy_edge_class
          field_defn.edge_class = @legacy_edge_class
        end

        field_defn.resolve = self.method(:resolve_field)
        field_defn.connection = connection?
        field_defn.connection_max_page_size = max_page_size
        field_defn.introspection = @introspection
        field_defn.complexity = @complexity
        field_defn.subscription_scope = @subscription_scope
        field_defn.ast_node = ast_node

        all_argument_definitions.each do |defn|
          arg_graphql = defn.deprecated_to_graphql
          field_defn.arguments[arg_graphql.name] = arg_graphql # rubocop:disable Development/ContextIsPassedCop -- legacy-related
        end

        # Support a passed-in proc, one way or another
        @resolve_proc = if @resolve
          @resolve
        elsif @function
          @function
        elsif @field
          @field.resolve_proc
        end

        # Ok, `self` isn't a class, but this is for consistency with the classes
        field_defn.metadata[:type_class] = self
        field_defn.arguments_class = GraphQL::Query::Arguments.construct_arguments_class(field_defn)
        field_defn
      end

      class MissingReturnTypeError < GraphQL::Error; end
      attr_writer :type

      def type
        @type ||= if @function
          Member::BuildType.parse_type(@function.type, null: false)
        elsif @field
          Member::BuildType.parse_type(@field.type, null: false)
        elsif @return_type_expr.nil?
          # Not enough info to determine type
          message = "Can't determine the return type for #{self.path}"
          if @resolver_class
            message += " (it has `resolver: #{@resolver_class}`, consider configuration a `type ...` for that class)"
          end
          raise MissingReturnTypeError, message
        else
          Member::BuildType.parse_type(@return_type_expr, null: @return_type_null)
        end
      rescue GraphQL::Schema::InvalidDocumentError, MissingReturnTypeError => err
        # Let this propagate up
        raise err
      rescue StandardError => err
        raise MissingReturnTypeError, "Failed to build return type for #{@owner.graphql_name}.#{name} from #{@return_type_expr.inspect}: (#{err.class}) #{err.message}", err.backtrace
      end

      def visible?(context)
        if @resolver_class
          @resolver_class.visible?(context)
        else
          true
        end
      end

      def accessible?(context)
        if @resolver_class
          @resolver_class.accessible?(context)
        else
          true
        end
      end

      def authorized?(object, args, context)
        if @resolver_class
          # The resolver _instance_ will check itself during `resolve()`
          @resolver_class.authorized?(object, context)
        else
          if (arg_values = context[:current_arguments])
            # ^^ that's provided by the interpreter at runtime, and includes info about whether the default value was used or not.
            using_arg_values = true
            arg_values = arg_values.argument_values
          else
            arg_values = args
            using_arg_values = false
          end
          if args.size > 0
            args = context.warden.arguments(self)
            args.each do |arg|
              arg_key = arg.keyword
              if arg_values.key?(arg_key)
                arg_value = arg_values[arg_key]
                if using_arg_values
                  if arg_value.default_used?
                    # pass -- no auth required for default used
                    next
                  else
                    application_arg_value = arg_value.value
                    if application_arg_value.is_a?(GraphQL::Execution::Interpreter::Arguments)
                      application_arg_value.keyword_arguments
                    end
                  end
                else
                  application_arg_value = arg_value
                end

                if !arg.authorized?(object, application_arg_value, context)
                  return false
                end
              end
            end
          end
          true
        end
      end

      # Implement {GraphQL::Field}'s resolve API.
      #
      # Eventually, we might hook up field instances to execution in another way. TBD.
      # @see #resolve for how the interpreter hooks up to it
      def resolve_field(obj, args, ctx)
        ctx.schema.after_lazy(obj) do |after_obj|
          # First, apply auth ...
          query_ctx = ctx.query.context
          # Some legacy fields can have `nil` here, not exactly sure why.
          # @see https://github.com/rmosolgo/graphql-ruby/issues/1990 before removing
          inner_obj = after_obj && after_obj.object
          ctx.schema.after_lazy(to_ruby_args(after_obj, args, ctx)) do |ruby_args|
            if authorized?(inner_obj, ruby_args, query_ctx)
              # Then if it passed, resolve the field
              if @resolve_proc
                # Might be nil, still want to call the func in that case
                with_extensions(inner_obj, ruby_args, query_ctx) do |extended_obj, extended_args|
                  # Pass the GraphQL args here for compatibility:
                  @resolve_proc.call(extended_obj, args, ctx)
                end
              else
                public_send_field(after_obj, ruby_args, query_ctx)
              end
            else
              err = GraphQL::UnauthorizedFieldError.new(object: inner_obj, type: obj.class, context: ctx, field: self)
              query_ctx.schema.unauthorized_field(err)
            end
          end
        end
      end

      # This method is called by the interpreter for each field.
      # You can extend it in your base field classes.
      # @param object [GraphQL::Schema::Object] An instance of some type class, wrapping an application object
      # @param args [Hash] A symbol-keyed hash of Ruby keyword arguments. (Empty if no args)
      # @param ctx [GraphQL::Query::Context]
      def resolve(object, args, ctx)
        if @resolve_proc
          raise "Can't run resolve proc for #{path} when using GraphQL::Execution::Interpreter"
        end
        begin
          # Unwrap the GraphQL object to get the application object.
          application_object = object.object

          Schema::Validator.validate!(validators, application_object, ctx, args)

          ctx.schema.after_lazy(self.authorized?(application_object, args, ctx)) do |is_authorized|
            if is_authorized
              public_send_field(object, args, ctx)
            else
              raise GraphQL::UnauthorizedFieldError.new(object: application_object, type: object.class, context: ctx, field: self)
            end
          end
        rescue GraphQL::UnauthorizedFieldError => err
          err.field ||= self
          ctx.schema.unauthorized_field(err)
        rescue GraphQL::UnauthorizedError => err
          ctx.schema.unauthorized_object(err)
        end
      rescue GraphQL::ExecutionError => err
        err
      end

      # @param ctx [GraphQL::Query::Context::FieldResolutionContext]
      def fetch_extra(extra_name, ctx)
        if extra_name != :path && extra_name != :ast_node && respond_to?(extra_name)
          self.public_send(extra_name)
        elsif ctx.respond_to?(extra_name)
          ctx.public_send(extra_name)
        else
          raise GraphQL::RequiredImplementationMissingError, "Unknown field extra for #{self.path}: #{extra_name.inspect}"
        end
      end

      private

      NO_ARGS = {}.freeze

      # Convert a GraphQL arguments instance into a Ruby-style hash.
      #
      # @param obj [GraphQL::Schema::Object] The object where this field is being resolved
      # @param graphql_args [GraphQL::Query::Arguments]
      # @param field_ctx [GraphQL::Query::Context::FieldResolutionContext]
      # @return [Hash<Symbol => Any>]
      def to_ruby_args(obj, graphql_args, field_ctx)
        if graphql_args.any? || @extras.any?
          # Splat the GraphQL::Arguments to Ruby keyword arguments
          ruby_kwargs = graphql_args.to_kwargs
          maybe_lazies = []
          # Apply any `prepare` methods. Not great code organization, can this go somewhere better?
          arguments(field_ctx).each do |name, arg_defn|
            ruby_kwargs_key = arg_defn.keyword

            if ruby_kwargs.key?(ruby_kwargs_key)
              loads = arg_defn.loads
              value = ruby_kwargs[ruby_kwargs_key]
              loaded_value = if loads && !arg_defn.from_resolver?
                if arg_defn.type.list?
                  loaded_values = value.map { |val| load_application_object(arg_defn, loads, val, field_ctx.query.context) }
                  field_ctx.schema.after_any_lazies(loaded_values) { |result| result }
                else
                  load_application_object(arg_defn, loads, value, field_ctx.query.context)
                end
              elsif arg_defn.type.list? && value.is_a?(Array)
                field_ctx.schema.after_any_lazies(value, &:itself)
              else
                value
              end

              maybe_lazies << field_ctx.schema.after_lazy(loaded_value) do |loaded_value|
                prepared_value = if arg_defn.prepare
                  arg_defn.prepare_value(obj, loaded_value)
                else
                  loaded_value
                end

                ruby_kwargs[ruby_kwargs_key] = prepared_value
              end
            end
          end

          @extras.each do |extra_arg|
            ruby_kwargs[extra_arg] = fetch_extra(extra_arg, field_ctx)
          end

          field_ctx.schema.after_any_lazies(maybe_lazies) do
            ruby_kwargs
          end
        else
          NO_ARGS
        end
      end

      def public_send_field(unextended_obj, unextended_ruby_kwargs, query_ctx)
        with_extensions(unextended_obj, unextended_ruby_kwargs, query_ctx) do |obj, ruby_kwargs|
          begin
            method_receiver = nil
            method_to_call = nil
            if @resolver_class
              if obj.is_a?(GraphQL::Schema::Object)
                obj = obj.object
              end
              obj = @resolver_class.new(object: obj, context: query_ctx, field: self)
            end

            # Find a way to resolve this field, checking:
            #
            # - A method on the type instance;
            # - Hash keys, if the wrapped object is a hash or responds to `#[]`
            # - A method on the wrapped object;
            # - Or, raise not implemented.
            #
            if obj.respond_to?(@resolver_method)
              method_to_call = @resolver_method
              method_receiver = obj
              # Call the method with kwargs, if there are any
              if ruby_kwargs.any?
                obj.public_send(@resolver_method, **ruby_kwargs)
              else
                obj.public_send(@resolver_method)
              end
            elsif obj.object.is_a?(Hash)
              inner_object = obj.object
              if @dig_keys
                inner_object.dig(*@dig_keys)
              elsif inner_object.key?(@method_sym)
                inner_object[@method_sym]
              else
                inner_object[@method_str]
              end
            elsif defined?(@hash_key) && obj.object.respond_to?(:[])
              obj.object[@hash_key]
            elsif obj.object.respond_to?(@method_sym)
              method_to_call = @method_sym
              method_receiver = obj.object
              if ruby_kwargs.any?
                obj.object.public_send(@method_sym, **ruby_kwargs)
              else
                obj.object.public_send(@method_sym)
              end
            else
              raise <<-ERR
            Failed to implement #{@owner.graphql_name}.#{@name}, tried:

            - `#{obj.class}##{@resolver_method}`, which did not exist
            - `#{obj.object.class}##{@method_sym}`, which did not exist
            - Looking up hash key `#{@method_sym.inspect}` or `#{@method_str.inspect}` on `#{obj.object}`, but it wasn't a Hash

            To implement this field, define one of the methods above (and check for typos)
            ERR
            end
          rescue ArgumentError
            assert_satisfactory_implementation(method_receiver, method_to_call, ruby_kwargs)
            # if the line above doesn't raise, re-raise
            raise
          end
        end
      end

      def assert_satisfactory_implementation(receiver, method_name, ruby_kwargs)
        method_defn = receiver.method(method_name)
        unsatisfied_ruby_kwargs = ruby_kwargs.dup
        unsatisfied_method_params = []
        encountered_keyrest = false
        method_defn.parameters.each do |(param_type, param_name)|
          case param_type
          when :key
            unsatisfied_ruby_kwargs.delete(param_name)
          when :keyreq
            if unsatisfied_ruby_kwargs.key?(param_name)
              unsatisfied_ruby_kwargs.delete(param_name)
            else
              unsatisfied_method_params << "- `#{param_name}:` is required by Ruby, but not by GraphQL. Consider `#{param_name}: nil` instead, or making this argument required in GraphQL."
            end
          when :keyrest
            encountered_keyrest = true
          when :req
            unsatisfied_method_params << "- `#{param_name}` is required by Ruby, but GraphQL doesn't pass positional arguments. If it's meant to be a GraphQL argument, use `#{param_name}:` instead. Otherwise, remove it."
          when :opt, :rest
            # This is fine, although it will never be present
          end
        end

        if encountered_keyrest
          unsatisfied_ruby_kwargs.clear
        end

        if unsatisfied_ruby_kwargs.any? || unsatisfied_method_params.any?
          raise FieldImplementationFailed.new, <<-ERR
Failed to call #{method_name} on #{receiver.inspect} because the Ruby method params were incompatible with the GraphQL arguments:

#{ unsatisfied_ruby_kwargs
    .map { |key, value| "- `#{key}: #{value}` was given by GraphQL but not defined in the Ruby method. Add `#{key}:` to the method parameters." }
    .concat(unsatisfied_method_params)
    .join("\n") }
ERR
        end
      end

      # Wrap execution with hooks.
      # Written iteratively to avoid big stack traces.
      # @return [Object] Whatever the
      def with_extensions(obj, args, ctx)
        if @extensions.empty?
          yield(obj, args)
        else
          # This is a hack to get the _last_ value for extended obj and args,
          # in case one of the extensions doesn't `yield`.
          # (There's another implementation that uses multiple-return, but I'm wary of the perf cost of the extra arrays)
          extended = { args: args, obj: obj, memos: nil, added_extras: nil }
          value = run_extensions_before_resolve(obj, args, ctx, extended) do |obj, args|
            if (added_extras = extended[:added_extras])
              args = args.dup
              added_extras.each { |e| args.delete(e) }
            end
            yield(obj, args)
          end

          extended_obj = extended[:obj]
          extended_args = extended[:args]
          memos = extended[:memos] || EMPTY_HASH

          ctx.schema.after_lazy(value) do |resolved_value|
            idx = 0
            @extensions.each do |ext|
              memo = memos[idx]
              # TODO after_lazy?
              resolved_value = ext.after_resolve(object: extended_obj, arguments: extended_args, context: ctx, value: resolved_value, memo: memo)
              idx += 1
            end
            resolved_value
          end
        end
      end

      def run_extensions_before_resolve(obj, args, ctx, extended, idx: 0)
        extension = @extensions[idx]
        if extension
          extension.resolve(object: obj, arguments: args, context: ctx) do |extended_obj, extended_args, memo|
            if memo
              memos = extended[:memos] ||= {}
              memos[idx] = memo
            end

            if (extras = extension.added_extras)
              ae = extended[:added_extras] ||= []
              ae.concat(extras)
            end

            extended[:obj] = extended_obj
            extended[:args] = extended_args
            run_extensions_before_resolve(extended_obj, extended_args, ctx, extended, idx: idx + 1) { |o, a| yield(o, a) }
          end
        else
          yield(obj, args)
        end
      end
    end
  end
end