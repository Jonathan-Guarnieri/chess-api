require 'rails_helper'

RSpec.describe CreateGameService, type: :service do
  describe '#call' do
    let!(:player1) { create(:user) }
    let!(:player2) { create(:user) }

    it 'creates a game with exactly two players' do
      game = described_class.new(player_ids: [ player1.id, player2.id ]).call

      expect(game).to be_a(Game)
      expect(game).to be_persisted
      expect([ game.white_player_id, game.black_player_id ]).to match_array([ player1.id, player2.id ])
    end

    it 'raises error if less than two players' do
      expect {
        described_class.new(player_ids: [ player1.id ]).call
      }.to raise_error("Should have exactly 2 players, found 1")
    end

    it 'raises error if more than two players' do
      player3 = create(:user)

      expect {
        described_class.new(player_ids: [ player1.id, player2.id, player3.id ]).call
      }.to raise_error("Should have exactly 2 players, found 3")
    end
  end
end
