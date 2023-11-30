# frozen_string_literal: true

# class RoomPolicy contains of methods for create rooms
class RoomPolicy < ApplicationPolicy

  def initialize(user, room)
    @user = user
    @room = room
  end

  def create?
    user_is_admin?
  end

  def show?
    user.present?
  end

  def user_is_admin?
    user && user&.admin?
  end

  def user_is_authenticated?
    user.present?
  end

  def user_is_regular?
    user && user&.user?
  end
end
