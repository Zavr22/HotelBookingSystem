# frozen_string_literal: true

# class RoomCheckJob contains job to check free rooms
class RoomCheckJob
  include Sidekiq::Job

  def perform
    Invoice.transaction do
      Invoice.where(is_deleted: false).joins(:request).where('requests.check_out_date < ?', Date.today).update_all(is_deleted: true)
      Room.increment_counter(:free_count, Invoice.where(is_deleted: true).joins(:request).select(:room_id))
    end
  end
end

