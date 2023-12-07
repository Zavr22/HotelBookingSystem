# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  describe 'allUsers' do
    let(:admin_user) { FactoryBot.create(:user, :admin) }
    let(:regular_user) { FactoryBot.create(:user) }
    let(:context) { {current_user: admin_user} }
    let(:query) do
      %(query{
        allUsers {
          id
          login
          role
        }
      })
    end

    subject(:result) do
      HotelSystemSchema.execute(query, context: {current_user: admin_user}).to_h
    end

    before do
      FactoryBot.create_list(:user, 3, role: 'admin')
    end

    it 'returns all users' do
      expect(result.dig('data', 'allUsers')&.length).to eq(User.count)

    end
  end
end
