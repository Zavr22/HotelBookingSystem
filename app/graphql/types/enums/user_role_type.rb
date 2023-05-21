# frozen_string_literal: true

module Types::Enums
  class UserRoleType < Types::BaseEnum
    description "Roles that a user can have, these define permissions levels. Most users will be `user`."

    value "USER", value: "user", description: "User is a regular user."
    value "ADMIN", value: "admin", description: "User is an admin and has the highest permissions."
  end
end