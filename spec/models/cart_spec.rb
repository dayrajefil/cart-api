require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'is invalid when total_price is negative' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
    end

    it 'includes error message when total_price is negative' do
      cart = described_class.new(total_price: -1)
      cart.valid?
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end

    it 'is valid when total_price is nil' do
      cart = described_class.new(total_price: nil)
      expect(cart.valid?).to be_truthy
    end

    it 'is valid when total_price is zero' do
      cart = described_class.new(total_price: 0)
      expect(cart.valid?).to be_truthy
    end
  end

  describe '#mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe '#remove_if_abandoned' do
    context 'when abandoned' do
      let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

      it 'destroys the cart' do
        shopping_cart.mark_as_abandoned
        expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
      end
    end

    context 'when not abandoned' do
      let!(:shopping_cart) { create(:shopping_cart) }

      it 'does not destroy the cart' do
        expect { shopping_cart.remove_if_abandoned }.not_to change { Cart.count }
      end
    end
  end

  describe '#recalculate_total' do
    let(:product) { create(:product, price: 15.0) }
    let(:cart) { create(:shopping_cart) }

    before { create(:cart_item, cart: cart, product: product, quantity: 2) }

    it 'updates total_price based on cart items' do
      expect { cart.recalculate_total }.to change { cart.reload.total_price.to_f }.to(30.0)
    end

    it 'updates last_interaction_at to current time' do
      cart.recalculate_total
      expect(cart.last_interaction_at).to be_within(2.seconds).of(Time.current)
    end
  end

  describe 'associations' do
    it 'destroys cart_items when cart is destroyed' do
      cart = create(:shopping_cart)
      create(:cart_item, cart: cart)
      expect { cart.destroy }.to change { CartItem.count }.by(-1)
    end
  end
end
