require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Solidstate' do

  describe 'inheritance' do
    it 'works' do
      expect(Subscriber.possible_states).to eq(['inactive', 'active', 'unsubscribed', 'disabled'])
      expect(PaidSubscriber.possible_states).to eq(['inactive', 'active', 'unsubscribed', 'disabled'])
    end
  end

end
