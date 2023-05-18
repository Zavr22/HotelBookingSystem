# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def initialize(current_user, user)
    @current_user = current_user
    @user = user


  end
end
