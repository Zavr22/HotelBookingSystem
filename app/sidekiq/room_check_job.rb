# frozen_string_literal: true

# class RoomCheckJob contains job to check free rooms
class RoomCheckJob
  include Sidekiq::Job

  def perform
    Invoice.transaction do
      invoices = Invoice.where(is_deleted: false).where('request.check_out_date < ?', Date.today)
      room_ids = invoices.joins(:request).pluck(:room_id)

      invoices.update_all(is_deleted: true)
      Room.where(id: room_ids).update_all('free_count = free_count + 1')
    end
  end
end

