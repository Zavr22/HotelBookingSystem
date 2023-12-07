# frozen_string_literal: true

Sidekiq::Cron::Job.create(
  name: 'RoomCheckJob',
  klass: 'RoomCheckJob',
  cron: '0 5 * * *',
  queue: 'high'
)
