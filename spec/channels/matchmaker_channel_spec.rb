require 'rails_helper'

RSpec.describe MatchmakerChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    stub_connection(current_user: user)
    allow(MatchmakerQueue).to receive(:add)
    allow(MatchmakerQueue).to receive(:remove)
    allow(MatchmakerJob).to receive(:perform_async)
  end

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
end
