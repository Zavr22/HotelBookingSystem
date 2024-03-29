# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id          :bigint           not null, primary key
#  free_count  :integer
#  name        :string
#  price       :float
#  room_class  :string
#  room_number :integer
#  total_count :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Room < ApplicationRecord
  has_many :invoice
  has_many :request
  has_one_attached :image

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) if image.attached?
  end

  scope :free, -> { where('free_count > 0') }
end
