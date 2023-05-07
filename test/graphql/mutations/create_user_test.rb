# frozen_string_literal: true
require_relative '../../../app/graphql/types/auth_credentials_input'
require 'test_helper'

class Mutations::CreateUserTest < ActiveSupport::TestCase
  def perform(args = {})
    Mutations::CreateUser.new(object: nil, field: nil, context: {}).resolve(**args)
  end

  test 'create new user' do
    user = perform(
        auth_provider: {
          credentials: {
            login: "test",
            password: "123456",
            role: "admin"
          }
        }
    )


    assert user.persisted?
    assert_equal user.login, 'test'
    assert_equal user.password, '123456'
    assert_equal user.role, 'admin'
  end
end


