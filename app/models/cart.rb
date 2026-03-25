class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def mark_as_abandoned
    update!(abandoned: true)
  end

  def remove_if_abandoned
    destroy! if abandoned?
  end

  def recalculate_total
    update!(total_price: cart_items.sum(&:total_price), last_interaction_at: Time.current)
  end
end
