# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::RoomType do
  describe "fields" do
    it "has the node field" do
      node_field = described_class.fields["id"]
      expect(node_field).to be_a(GraphQL::Schema::Field)
      expect(node_field.type.to_type_signature).to eq("ID!")
    end
  end
end
