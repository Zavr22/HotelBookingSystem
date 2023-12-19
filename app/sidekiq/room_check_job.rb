# frozen_string_literal: true

# class RoomCheckJob contains job to check free rooms
class RoomCheckJob
  include Sidekiq::Job

  def perform
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE rooms
      SET free_count = free_count + (
        SELECT COUNT(*)
        FROM invoices
        INNER JOIN requests ON invoices.request_id = requests.id
        WHERE invoices.room_id = rooms.id
          AND invoices.is_deleted = FALSE
          AND requests.check_out_date < CURRENT_DATE
      )
      WHERE id IN (
        SELECT DISTINCT requests.room_id
        FROM invoices
        INNER JOIN requests ON invoices.request_id = requests.id
        WHERE invoices.is_deleted = FALSE
        AND requests.check_out_date < CURRENT_DATE
      );
    SQL

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE invoices
      SET is_deleted = TRUE
      FROM requests
      WHERE invoices.request_id = requests.id
        AND invoices.is_deleted = FALSE
        AND requests.check_out_date < CURRENT_DATE;
    SQL
  end
end
