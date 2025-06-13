require 'rails_helper'

RSpec.describe MatchmakerChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    Timecop.freeze(Time.now)

    stub_connection(current_user: user)
    allow(MatchmakerQueue).to receive(:add)
    allow(MatchmakerQueue).to receive(:remove)
    allow(MatchmakerJob).to receive(:perform_async)
  end

  after { Timecop.return }

  it 'subscribes, streams for the user, and enqueues them in the matchmaker queue' do
    subscribe

    expect(subscription).to be_confirmed
    expect(MatchmakerQueue).to have_received(:add).with(user.id).once
    expect(subscription).to have_stream_for(user)
    expect(MatchmakerJob).to have_received(:perform_async).once
  end

  it 'unsubscribes and removes the user from the queue' do
    subscribe
    unsubscribe

    expect(MatchmakerQueue).to have_received(:remove).with(user.id).once
  end

  describe 'keep_alive' do
    it 'renew the user to the queue if they are subscribed' do
      allow(MatchmakerQueue).to receive(:include?).and_return(true)

      subscribe

      expect(MatchmakerQueue).to receive(:add).with(user.id)
      perform :keep_alive
    end

    it 'broadcasts not_subscribed if the user is not in the queue' do
      allow(MatchmakerQueue).to receive(:include?).and_return(false)

      subscribe

      expect(MatchmakerQueue).not_to receive(:add)
      expect { perform :keep_alive }.to have_broadcasted_to(user).with(action: 'not_subscribed')
    end
  end
end
