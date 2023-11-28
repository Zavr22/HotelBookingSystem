# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  login      :string
#  password   :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :requests, dependent: :destroy
  has_many :invoices, dependent: :destroy
  enum role: {
    user: 'user',
    admin: 'admin'
  }
end
