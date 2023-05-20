# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_is_admin?
    user && user&.admin?
  end
end
