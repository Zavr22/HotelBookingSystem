class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :request
  belongs_to :room
end
