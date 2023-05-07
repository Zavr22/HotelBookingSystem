class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :request
  has_one :room, dependent: :destroy
end
