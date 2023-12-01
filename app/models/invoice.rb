# == Schema Information
#
# Table name: invoices
#
#  id         :bigint           not null, primary key
#  amount_due :float
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  request_id :bigint           not null
#  room_id    :integer
#  user_id    :bigint           not null
#
# Indexes
#
#  index_invoices_on_request_id  (request_id)
#  index_invoices_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (request_id => requests.id)
#  fk_rails_...  (user_id => users.id)
#
class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :request
  belongs_to :room, optional:true
end
