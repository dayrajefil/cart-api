FactoryBot.define do
  factory :cart_item do
    association :cart, factory: :shopping_cart
    association :product
    quantity { 1 }
  end
end
