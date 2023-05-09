# frozen_string_literal: true

# frozen_string_literal: true

require 'test_helper'

class Mutations::CreateRequestTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mutation = Mutations::CreateRequest.new(object: nil, context: { current_user: @user }, field: nil)
  end

  test 'creates a new request' do
    req_credentials = {
      capacity: 2,
      apart_class: 'lux',
      duration: 5
    }

    assert_difference 'Request.count' do
      @mutation.resolve(reqCredentials: req_credentials)
    end

    request = Request.last
    assert_equal @user.id, request.user_id
    assert_equal req_credentials[:capacity], request.capacity
    assert_equal req_credentials[:apart_class], request.apart_class
    assert_equal req_credentials[:duration], request.duration
  end

  test 'does not create a new request if user is not authenticated' do
    mutation = Mutations::CreateRequest.new(object: nil, context: { current_user: nil }, field: nil)
    req_credentials = {
      capacity: 2,
      apart_class: 'lux',
      duration: 5,
      user_id: users(:one).id # pass in the user_id of the authenticated user
    }

    assert_no_difference 'Request.count' do
      assert_raises() do
        mutation.resolve(reqCredentials: req_credentials)
      end
    end
  end
end
