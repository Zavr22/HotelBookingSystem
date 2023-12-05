# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomCheckJob, type: :job do
  describe '#perform' do
    let(:worker) { RoomCheckJob.new }

    it 'updates room free_count for expired invoices' do
      room = FactoryBot.create(:room, free_count: 5)
      user = FactoryBot.create(:user)
      request = FactoryBot.create(:request, check_out_date: Date.yesterday, room: room, user: user)
      invoice = FactoryBot.create(:invoice, request: request)

      Sidekiq::Testing.inline! do
        worker.perform

        room.reload

        expect(room.free_count).to eq(6)
      end
    end

    it 'does not update room free_count for non-expired invoices' do
      room = FactoryBot.create(:room, free_count: 5)
      user = FactoryBot.create(:user)
      request = FactoryBot.create(:request, check_out_date: Date.tomorrow, room: room, user: user)
      invoice = FactoryBot.create(:invoice, request: request)

      Sidekiq::Testing.inline! do
        worker.perform


        room.reload

        expect(room.free_count).to eq(5)
      end
    end
  end
end
