require 'bundler/setup'
require 'active_record'
require_relative '../lib/solidstate'

ActiveRecord::Base.establish_connection(
  "adapter"  => "sqlite3",
  "database" => ':memory:'
)

# ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

ActiveRecord::Schema.define :version => 0 do
  create_table "subscribers", :force => true do |t|
    t.string   "state", default: "inactive"
  end
end

class Subscriber < ActiveRecord::Base
  include SolidState

  states :inactive, :active, :unsubscribed, :disabled do
    transitions :from => :inactive, :to => :active
    transitions :from => :active, :to => [:unsubscribed, :disabled]
    transitions :from => :unsubscribed, :to => :active
  end
end
