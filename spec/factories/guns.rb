FactoryBot.define do
  factory :gun do
    name { "MyString" }
    type { "" }
    caliber { 1.5 }
    magazine_size { 1 }
    user { nil }
  end
end
