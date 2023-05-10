# frozen_string_literal: true

module ActiveRecord::TestFixtures
  def run_in_transaction?
    use_transactional_tests &&
      !self.class.uses_transaction?(method_name) # this monkeypatch changes `name` to `method_name`
  end
end
