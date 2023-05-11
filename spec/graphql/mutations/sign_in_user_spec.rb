# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe Mutations::SignInUser do
    def perform(args = {}, ctx = { session: {} })
      described_class.new(object: nil, field: nil, context: ctx).resolve(credentials: nil)
    end

    def create_user
      FactoryBot.create(:user, login: 'Test', password: '123', role: 'admin')
    end

    describe 'success' do
      it 'signs in a user' do
        user = create_user

        result = perform(
          credentials: {
            login: user.login,
            password: user.password
          }
        )

        expect(result[:token]).to be_present if result
        expect(result[:user]).to eq(user) if result
      end
    end

    describe 'failure' do
      context 'because no credentials' do
        it 'does not sign in a user' do
          expect(perform).to be_nil
        end
      end

      context 'because wrong login' do
        it 'does not sign in a user' do
          expect(perform(credentials: { login: 'wrong' })).to be_nil
        end
      end

      context 'because wrong password' do
        it 'does not sign in a user' do
          user = create_user
          expect(perform(credentials: { login: user.login, password: 'wrong' })).to be_nil
        end
      end
    end
  end
end
