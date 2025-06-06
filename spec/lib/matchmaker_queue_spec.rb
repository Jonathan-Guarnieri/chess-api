require "rails_helper"

RSpec.describe MatchmakerQueue do
  let(:redis) { RedisClientWrapper.instance }
  let(:user_id) { "user_123" }
  let(:ttl_seconds) { 5 }
  let(:expire_at) { Time.now.to_f + ttl_seconds }

  before do
    Timecop.freeze(Time.now)
    redis.del(described_class::KEY)
    allow(ENV).to receive(:[]).with("MATCHMAKER_ENQUEUE_TTL_SECONDS").and_return(ttl_seconds.to_s)
  end

  after { Timecop.return }

  it "has a valid Redis key" do
    expect(described_class::KEY).to eq("matchmaker")
  end

  describe ".add" do
    it "adds user to queue with TTL" do
      expect {
        described_class.add(user_id)
      }.to change { redis.zcard(described_class::KEY) }.by(1)

      score = redis.zscore(described_class::KEY, user_id).to_f
      expect(score).to be(Time.now.to_f + ttl_seconds)
    end

    it "raises error if TTL is invalid" do
      allow(ENV).to receive(:[]).with("MATCHMAKER_ENQUEUE_TTL_SECONDS").and_return(nil)
      expect { described_class.add(user_id) }.to raise_error("MATCHMAKER_ENQUEUE_TTL_SECONDS env not set or invalid")
    end
  end

  describe ".remove" do
    it "removes user from queue" do
      add_user_with_ttl(user_id, expire_at)
      expect {
        described_class.remove(user_id)
      }.to change { described_class.size }.by(-1)
    end
  end

  describe ".pop" do
    it "returns and removes oldest users from queue" do
      uids = %w[user1 user2 user3]

      # Add users with different scores
      uids.map.with_index do |id, i|
        add_user_with_ttl(id, expire_at + i)
      end

      popped = described_class.pop(2)
      expect([ popped ]).to contain_exactly(uids[0..1])
      expect(described_class.all).to eq([ uids[2] ])
    end

    it "returns empty if count is invalid" do
      expect(described_class.pop(0)).to eq([])
      expect(described_class.pop(-1)).to eq([])
      expect(described_class.pop(nil)).to eq([])
    end
  end

  describe ".size" do
    it "returns correct size before and after expiration purge" do
      add_user_with_ttl(user_id, expire_at)

      expect(described_class.size).to eq(1)

      Timecop.travel(Time.now + ttl_seconds + 1) do
        expect(described_class.size).to eq(0)
      end
    end
  end

  describe ".all" do
    it "returns correct list before and after expiration purge" do
      add_user_with_ttl(user_id, expire_at)

      expect(described_class.all).to eq([ user_id ])

      Timecop.travel(Time.now + ttl_seconds + 1) do
        expect(described_class.all).to eq([])
      end
    end
  end

  def add_user_with_ttl(user_id, expire_at)
    redis.zadd(described_class::KEY, expire_at, user_id)
  end
end
