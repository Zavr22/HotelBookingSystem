# frozen_string_literal: true

class InvoicePolicy < ApplicationPolicy
  def initialize(user, invoice)
    @user = user
    @invoice = invoice
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
end
