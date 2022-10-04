class Quote < ApplicationRecord
  validates :name, presence: true

  # Keep the order of the quotes consistent even if we refresh the page. 
  # Since we're prepending new quotes to the top of the list, we want to make sure
  # they're ordered by id decending.
  scope :ordered, -> { order(id: :desc) }
end
