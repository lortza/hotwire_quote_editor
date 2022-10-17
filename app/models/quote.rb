# Be sure to restart the Rails console after making any changes to the callbacks in here.
# Otherwise you'll get unexpected & confusing results. #learned-the-hard-way

class Quote < ApplicationRecord
  validates :name, presence: true

  # Keep the order of the quotes consistent even if we refresh the page.
  # Since we're prepending new quotes to the top of the list, we want to make sure
  # they're ordered by id decending.
  scope :ordered, -> { order(id: :desc) }

  # Action Cable code:
  # after_create_commit == a callback every time a new quote is created
  # The second part of the expression in the lambda is more complex. It instructs our
  # app that the HTML of the created quote should be broadcast to users subscribed to
  # the "quotes" stream and prepended to the DOM node with the id of "quotes".
  # Using `broadcast_prepend_later_to` instead of `broadcast_prepend_to`runs this task
  # in a job and is the preferred, more-performant way.
  after_create_commit -> { broadcast_prepend_later_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }

  # We can streamline the above line by removing the explicit "target" since the default
  # target is the plural of the model name. The partial and the locals are also following
  # naming conventions so we can shorten to this:
  # after_create_commit -> { broadcast_prepend_later_to "quotes" }

  # We're doing the shorthand version for the others.
  # Notice that we're replacing instead of prepending for update.
  # Otherwise it is a confusing user experience.
  after_update_commit -> { broadcast_replace_later_to "quotes" }
  # After destroy, we remove the element. We don't run it as a job because the record
  # would be missing when the job tried to find it.
  after_destroy_commit -> { broadcast_remove_to "quotes" }


  # We could replace all of those individual callbacks with this one heckin chonker version:
  # broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
end
