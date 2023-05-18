# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def initialize(user, request)
    @user = user
    @request = request
  end

  def user_is_authenticated?
    user.present?
  end
end
