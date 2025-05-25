FactoryBot.define do
  factory :user do
    name { 'John' }
    last_name { 'Doe' }
    login { 'johndoe' }
    email { 'john@example.com' }
    phone_number { '1234567890' }
    password { 'password' }
    uuid { SecureRandom.uuid }
    parameters { {} }
  end
end