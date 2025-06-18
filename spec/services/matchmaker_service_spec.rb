require "rails_helper"

RSpec.describe MatchmakerService do
  subject(:service) { described_class.new }
  let(:player1) { "1" }
  let(:player2) { "2" }

  before do
    allow(CreateGameService).to receive(:call)
    allow(MatchmakerChannel).to receive(:broadcast_to)
  end

  describe "#call" do
    context "when there are two players in the queue" do
      before do
        MatchmakerQueue.add(player1)
        MatchmakerQueue.add(player2)
      end

      it "creates a game" do
        service.call
        expect(CreateGameService).to have_received(:call).with(player_ids: [ player1, player2 ])
      end

      it "broadcasts to both players" do
        service.call
        expect(MatchmakerChannel).to have_received(:broadcast_to).with(player1, { action: "match_found" })
        expect(MatchmakerChannel).to have_received(:broadcast_to).with(player2, { action: "match_found" })
      end

      it "clears the queue" do
        service.call
        expect(MatchmakerQueue.size).to eq(0)
      end

      it "does not try again later" do
        service.call
        expect(service.try_again_later?).to eq(false)
      end

      it { expect { service.call }.to acquire_and_release_redis_lock("matchmaker_lock") }
    end

    context "when there are not enough players in the queue" do
      before do
        MatchmakerQueue.add(player1)
      end

      it "does not create a game" do
        service.call
        expect(CreateGameService).not_to have_received(:call)
      end

      it "does not broadcast to the player" do
        service.call
        expect(MatchmakerChannel).not_to have_received(:broadcast_to)
      end

      it "does not clear the queue" do
        service.call
        expect(MatchmakerQueue.size).to eq(1)
      end

      it "try again later" do
        service.call
        expect(service.try_again_later?).to eq(true)
      end
    end

    context "when the lock is already taken" do
      let(:redis) { RedisClientWrapper.instance }
      before do
        redis.set("matchmaker_lock", "some-other-token", ex: 5)
      end

      it "does not perform matchmaking" do
        MatchmakerQueue.add(player1)
        MatchmakerQueue.add(player2)

        service.call

        expect(CreateGameService).not_to have_received(:call)
        expect(MatchmakerChannel).not_to have_received(:broadcast_to)
        expect(MatchmakerQueue.size).to eq(2)
        expect(service.try_again_later?).to eq(true)
      ensure
        redis.del("matchmaker_lock")
      end
    end
  end
end
