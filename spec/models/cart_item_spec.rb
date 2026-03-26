require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'is invalid when quantity is zero' do
      cart_item = described_class.new(quantity: 0)
      expect(cart_item.valid?).to be_falsey
    end

    it 'includes error message when quantity is zero' do
      cart_item = described_class.new(quantity: 0)
      cart_item.valid?
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is invalid when quantity is negative' do
      cart_item = described_class.new(quantity: -1)
      expect(cart_item.valid?).to be_falsey
    end

    it 'includes error message when quantity is negative' do
      cart_item = described_class.new(quantity: -1)
      cart_item.valid?
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is invalid without a cart' do
      cart_item = described_class.new(product: create(:product), quantity: 1)
      expect(cart_item.valid?).to be_falsey
    end

    it 'includes error message when cart is absent' do
      cart_item = described_class.new(product: create(:product), quantity: 1)
      cart_item.valid?
      expect(cart_item.errors[:cart]).to include("must exist")
    end

    it 'is invalid without a product' do
      cart_item = described_class.new(cart: create(:shopping_cart), quantity: 1)
      expect(cart_item.valid?).to be_falsey
    end

    it 'includes error message when product is absent' do
      cart_item = described_class.new(cart: create(:shopping_cart), quantity: 1)
      cart_item.valid?
      expect(cart_item.errors[:product]).to include("must exist")
    end
  end

  describe '#total_price' do
    it 'returns quantity multiplied by product price' do
      product = create(:product, price: 10.0)
      cart_item = described_class.new(quantity: 3, product: product)
      expect(cart_item.total_price).to eq(30.0)
    end
  end
end
