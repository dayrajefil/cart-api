require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'when validating' do
    it 'is invalid without a name' do
      product = described_class.new(price: 100)
      expect(product.valid?).to be_falsey
    end

    it 'includes error message when name is absent' do
      product = described_class.new(price: 100)
      product.valid?
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      product = described_class.new(name: 'Widget')
      expect(product.valid?).to be_falsey
    end

    it 'includes error message when price is absent' do
      product = described_class.new(name: 'Widget')
      product.valid?
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'is invalid when price is negative' do
      product = described_class.new(name: 'Widget', price: -1)
      expect(product.valid?).to be_falsey
    end

    it 'includes error message when price is negative' do
      product = described_class.new(name: 'Widget', price: -1)
      product.valid?
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end

    it 'is valid with name and non-negative price' do
      product = described_class.new(name: 'Widget', price: 0)
      expect(product.valid?).to be_truthy
    end
  end
end
