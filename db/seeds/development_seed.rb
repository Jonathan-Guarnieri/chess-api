class DevelopmentSeed
  def self.run
    unless Rails.env.development?
      raise "DevelopmentSeed should only be run in development environment"
    end

    puts "Seeding development data..."
    users.each { |u| upsert_user(u) }
  end

  def self.users
    [
      { email: "e@mail.com", nickname: "Ultra Mega User", password: "password123" },
      { email: "opponent@mail.com", nickname: "Poor Opponent", password: "password123" }
    ]
  end
  private_class_method :users

  def self.upsert_user(user_data)
    user = User.find_or_initialize_by(email: user_data[:email])
    user.nickname = user_data[:nickname]
    user.password = user_data[:password]
    user.save! if user.changed?
    puts "Seeded user: #{user.email}"
  end
  private_class_method :upsert_user
end

DevelopmentSeed.run
