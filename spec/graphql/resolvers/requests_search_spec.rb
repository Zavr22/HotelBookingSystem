# frozen_string_literal: true

require "rails_helper"

module Resolvers
  RSpec.describe RequestsSearch do
      describe "apply_filter" do
        let!(:user1) { FactoryBot.create(:user) }
        let!(:user2) { FactoryBot.create(:user) }
        let!(:request1) { FactoryBot.create(:request, user: user1) }
        let!(:request2) { FactoryBot.create(:request, user: user2) }
        let!(:request3) { FactoryBot.create(:request, user: user1) }

        it "filters requests by user_id" do
          resolver = Resolvers::RequestsSearch.new
          value = { user_id: user1.id }
          result = resolver.apply_filter(Request.all, value)

          expect(result).to contain_exactly(request1, request3)
        end
      end

      describe "fetch_results" do
        let(:admin_user) { FactoryBot.create(:user, :admin) }
        let(:regular_user) { FactoryBot.create(:user) }

        before do
          FactoryBot.create_list(:request, 5)
        end

        context "when the current user is an admin" do
          it "returns all requests" do
            resolver = Resolvers::RequestsSearch.new
            resolver.instance_variable_set(:@context, { current_user: admin_user })

            result = resolver.fetch_results

            expect(result).to eq(Request.all)
          end
        end

        context "when the current user is a regular user" do
          it "raises an execution error" do
            resolver = Resolvers::RequestsSearch.new
            resolver.instance_variable_set(:@context, { current_user: regular_user })

            expect { resolver.fetch_results }.to raise_error(GraphQL::ExecutionError, "You need to be admin to perform this action")
          end
        end
      end
  end
end
