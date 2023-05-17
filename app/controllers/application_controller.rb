# frozen_string_literal: true

# application controller
class ApplicationController < ActionController::Base
  include Pundit::Authorization
end
