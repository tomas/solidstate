$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'bundler/setup'
require 'solidstate'

class Subscriber
  include SolidState

  states :inactive, :active, :unsubscribed, :disabled do
    transitions :from => :inactive, :to => :active
    transitions :from => :active, :to => [:unsubscribed, :disabled]
    transitions :from => :unsubscribed, :to => :active
  end
end

class PaidSubscriber < Subscriber

end