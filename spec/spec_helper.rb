# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'dragonfly-activerecord/migration'
require 'active_record'

DATABASE = Pathname.new 'test.sqlite3'

def get_connection_hash
  case ENV.fetch('DAR_ADAPTER', 'sqlite3mem')
  when 'postgresql'
    {
      :adapter      => 'postgresql',
      :database     => 'dar_test',
      :host         => 'localhost',
      :min_messages => 'warning',
      :username     => ENV['DAR_DB_USER']
    }
  when 'mysql'
    {
      :adapter      => 'mysql2',
      :database     => 'dar_test',
      :host         => 'localhost',
      :username     => ENV['DAR_DB_USER']
    }
  when 'sqlite3'
    {
      :adapter      => 'sqlite3',
      :database     => DATABASE.to_s
    }
  when 'sqlite3mem'
    {
      :adapter      => 'sqlite3',
      :database     => ':memory:'
    }
  end
end


class TestMigration < ActiveRecord::Migration
  include Dragonfly::ActiveRecord::Migration
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'


  config.before(:each) do
    # Connect to & cleanup test database
    ActiveRecord::Base.establish_connection(get_connection_hash)

    %w(storage_files storage_chunks).each do |table_name|
      ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{table_name};"
    end

    def prepare_database
      silence_stream(STDOUT) do
        TestMigration.new.up
      end
    end
  end

  config.after(:each) do
    DATABASE.delete if DATABASE.exist?
  end
end
