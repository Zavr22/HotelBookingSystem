class User < ApplicationRecord
  has_many :requests, dependent: :destroy
  has_many :invoices, dependent: :destroy
end
