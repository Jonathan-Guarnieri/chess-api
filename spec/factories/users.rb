FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "Joaozinho #{n} da Silva" }
    sequence(:email) { |n| "person#{n}@example.com" }
    password { "password123" }
  end
end
