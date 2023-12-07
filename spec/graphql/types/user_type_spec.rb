# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::UserType do
  describe 'fields' do
    it 'has the node field' do
      node_field = described_class.fields['node']
      expect(node_field).to be_a(GraphQL::Schema::Field)
      expect(node_field.type.to_type_signature).to eq('Node')
    end
    it 'has the nodes field' do
      node_field = described_class.fields['nodes']
      expect(node_field).to be_a(GraphQL::Schema::Field)
      expect(node_field.type.to_type_signature).to eq('[Node]!')
    end
  end
end

