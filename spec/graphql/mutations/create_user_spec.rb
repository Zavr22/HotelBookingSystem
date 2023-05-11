# frozen_string_literal: true

require 'rails_helper'
module Mutations
  RSpec.describe CreateUser do
    def perform(args = {})
      described_class.new(object: nil, field: nil, context: {}).resolve(**args)
    end

    describe 'Create a new user' do
      it 'creates a new user' do
        user = perform(
          auth_provider: {
            credentials: {
              login: "test",
              password: "123456",
              role: "admin"
            }
          }
        )

        expect(user).to be_persisted
        expect(user.login).to eq('test')
        expect(user.password).to eq('123456')
        expect(user.role).to eq('admin')
      end
    end
  end
end
