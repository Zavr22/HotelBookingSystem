# frozen_string_literal: true

# class RoomCheckJob contains job to check free rooms
class RoomCheckJob
  include Sidekiq::Job

  def perform
    invoices = Invoice.all

    invoices.each do |invoice|
      if invoice.request.check_out_date < Date.today
        update_room_free_count(invoice.request.room)
      end
    end
  end

  private

  def update_room_free_count(room)
    room.update(free_count: room.free_count + 1)
  end
end
