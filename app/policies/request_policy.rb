# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def initialize(user, request)
    @user = user
    @request = request
  end

  def user_is_regular?
    user && user&.user?
  end
  def user_is_admin?
    user && user&.admin?
  end
end
