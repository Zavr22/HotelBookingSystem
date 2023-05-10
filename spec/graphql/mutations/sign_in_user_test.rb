# frozen_string_literal: true

require 'test_helper'

class Mutations::SignInUserTest < ActiveSupport::TestCase
  def perform(args = {})
    Mutations::SignInUser.new(object: nil, field: nil, context: { session: {} }).resolve(**args)
  end

  def create_user
    User.create!(
      login: 'Test',
      password: '123',
      role: 'admin'
      )
  end

  test 'success' do
    user = create_user

    result = perform(
      credentials: {
        login: user.login,
        password: user.password
      }
    )

    assert result[:token].present?
    assert_equal result[:user], user
  end

  test 'failure because no credentials' do
    assert_nil perform
  end

  test 'failure because wrong login' do
    assert_nil perform(credentials: { login: 'wrong'})
  end

  test 'failure because wrong password' do
    user = create_user
    assert_nil perform(credentials: { login: user.login, password: 'wrong'})

  end
end
