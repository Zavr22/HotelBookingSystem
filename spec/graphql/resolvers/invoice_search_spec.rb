# frozen_string_literal: true

require 'rails_helper'
require 'database_cleaner'
module Resolvers

  RSpec.describe InvoiceSearch do
    describe 'apply_filter' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:user2) { FactoryBot.create(:user) }
      let!(:admin) { FactoryBot.create(:user, :admin) }
      let!(:invoice1) { FactoryBot.create(:invoice, user_id: user.id, created_at: Time.new) }
      let!(:invoice2) { FactoryBot.create(:invoice, user_id: user2.id, created_at: 1.hour.ago) }
      let!(:invoice3) { FactoryBot.create(:invoice, user_id: user.id, created_at: 2.hours.ago) }


      it 'applies user_id filter' do
        filter = { user_id: user.id }
        resolver = Resolvers::InvoiceSearch.new
        result = resolver.apply_filter(Invoice.all, filter)

        expect(result).to contain_exactly(invoice1, invoice3)
      end
    end

    describe 'fetch_results' do
      let!(:admin) { FactoryBot.create(:user, role: 'admin') }
      let!(:user) { FactoryBot.create(:user, role: 'user') }
      let!(:invoice1) { FactoryBot.create(:invoice, user_id: admin.id) }
      let!(:invoice2) { FactoryBot.create(:invoice, user_id: user.id) }

      context 'when the user is an admin' do
        it 'returns all invoices' do
          resolver = Resolvers::InvoiceSearch.new
          resolver.instance_variable_set(:@context, { current_user: admin })
          result = resolver.fetch_results

          invoices = result.to_a # Преобразуйте ActiveRecord::Relation в массив

          expect(invoices).not_to be_empty
          expect(invoices.length).to eq(Invoice.count)
        end
      end


      context 'when the user is a regular user' do
        it 'returns only their invoices' do
          resolver = Resolvers::InvoiceSearch.new
          resolver.instance_variable_set(:@context, { current_user: user })
          result = resolver.fetch_results

          expect(result).to contain_exactly(invoice2)
        end
      end

      context 'when the user is not authenticated' do
        it 'raises an error' do
          expect {
            resolver = described_class.new
            result = resolver.fetch_results
          }.to raise_error(GraphQL::ExecutionError, 'You need to authenticate to perform this action')
        end
      end
    end

    describe 'apply_order_by_with_created_at_asc' do
      it 'returns invoices in ascending order by created_at' do
        user = FactoryBot.create(:user, :admin)
        resolver = Resolvers::InvoiceSearch.new
        resolver.instance_variable_set(:@context, { current_user: user })
        result = resolver.apply_order_by_with_created_at_asc(Invoice.all)
        expect(result).to eq(result.sort_by(&:created_at))
      end
    end

    describe 'apply_order_by_with_created_at_desc' do
      before(:all) do
        DatabaseCleaner.strategy = :truncation
        DatabaseCleaner.clean
      end
      it 'returns invoices in descending order by created_at' do
        user = FactoryBot.create(:user, :admin)
        resolver = Resolvers::InvoiceSearch.new
        result = resolver.apply_order_by_with_created_at_desc(Invoice.all)
        expect(result).to eq(Invoice.all.reverse)
      end
    end
  end
end