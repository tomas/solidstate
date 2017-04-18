require 'bundler/setup'
require 'mongo_mapper'
require_relative '../lib/solidstate'

class Person
  include MongoMapper::Document
  include SolidState

  STATES = %w(awake sleeping)

  key :state, String, :default => STATES.first
  # ensure_index :state

  states *STATES
end
