require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    context 'when marking abandoned carts' do
      let!(:inactive_cart) { create(:shopping_cart, last_interaction_at: 3.hours.ago, abandoned: false) }
      let!(:active_cart) { create(:shopping_cart, last_interaction_at: 1.hour.ago, abandoned: false) }

      it 'marks cart as abandoned after 3 hours of inactivity' do
        expect { described_class.new.perform }.to change { inactive_cart.reload.abandoned }.from(false).to(true)
      end

      it 'does not mark active cart as abandoned' do
        described_class.new.perform
        expect(active_cart.reload.abandoned).to be false
      end
    end

    context 'when removing abandoned carts' do
      let!(:old_abandoned_cart) { create(:shopping_cart, abandoned: true, last_interaction_at: 7.days.ago) }
      let!(:recent_abandoned_cart) { create(:shopping_cart, abandoned: true, last_interaction_at: 6.days.ago) }

      it 'removes cart abandoned for more than 7 days' do
        expect { described_class.new.perform }.to change { Cart.count }.by(-1)
      end

      it 'does not remove cart abandoned for less than 7 days' do
        described_class.new.perform
        expect(Cart.exists?(recent_abandoned_cart.id)).to be true
      end
    end

    context 'when there are no carts' do
      it 'does not raise any errors' do
        expect { described_class.new.perform }.not_to raise_error
      end
    end

    context 'when cart has nil last_interaction_at' do
      let!(:cart_without_interaction) { create(:shopping_cart, last_interaction_at: nil, abandoned: false) }

      it 'does not mark it as abandoned' do
        described_class.new.perform
        expect(cart_without_interaction.reload.abandoned).to be false
      end
    end
  end
end
