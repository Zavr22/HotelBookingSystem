class User < ApplicationRecord
  has_many :requests, dependent: :destroy
  has_many :invoices, dependent: :destroy
  enum role: {
    user: 'user',
    admin: 'admin'
  }
end
