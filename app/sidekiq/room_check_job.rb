# frozen_string_literal: true

# class RoomCheckJob contains job to check free rooms
class RoomCheckJob
  include Sidekiq::Job

  def perform
    invoices = Invoice.all.where(is_deleted: false)

    invoices.each do |invoice|
      if invoice.request.check_out_date < Date.today
        update_room_free_count(invoice.request.room)
        update_invoice_status(invoice)
      end
    end
  end

  private

  def update_room_free_count(room)
    room.update(free_count: room.free_count + 1)
  end
  
  def update_invoice_status(invoice)
    invoice.update(is_deleted: true)
  end
end
