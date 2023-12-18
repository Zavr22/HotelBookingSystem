# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SignInUser do
    let(:user) { FactoryBot.create(:user, login: 'testuser', password: 'password', role: 'admin') }

    let(:query) do
      <<~GQL
        mutation {
          signInUser(input: {
            credentials: {
              login: "#{user.login}",
              password: "#{user.password}",
              role: "admin"
            }
          }) {
            token,
            user {
              id
            }
          }
        }
      GQL
    end

    subject(:result) do
      context = { session: {} }
      HotelSystemSchema.execute(query, context: context).to_h
    end

    describe 'Sign in a user' do
      it 'signs in user and returns token' do
        expect(result.dig('data', 'signInUser', 'token')).not_to be_nil
        expect(result.dig('data', 'signInUser', 'user', 'id')).to eq(user.id.to_s)
      end

      it 'fails to sign in with incorrect credentials' do
        incorrect_query = <<~GQL
          mutation {
            signInUser(input: {
              credentials: {
                login: "wrong",
                password: "wrong",

                role: "admin"
              }
            }) {
              token
              user {
                id
              }
            }
          }
        GQL

        incorrect_result = HotelSystemSchema.execute(incorrect_query, context: nil).to_h
        puts incorrect_result
        expect(incorrect_result['data']['signInUser']).to be_nil
      end
    end
  end
end
