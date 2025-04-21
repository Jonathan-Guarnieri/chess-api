class CreateGame
  def initialize(players_ids:)
    @players_ids = players_ids
  end

  def call
    find_users
    raise "Not enough players" if @players.size < 2
    raise "Too many players" if @players.size > 2

    white_player, black_player = @players.sample(2)

    game = Game.create!(white_player:, black_player:)
  end

  private

  def find_users
    @players = User.where(id: @players_ids)
  end
end
