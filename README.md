# README

Following this tutorial: https://www.hotrails.dev/turbo-rails

* Rails 7
* Ruby 3
* Set up app from scratch with `bin/setup`
* Run server with `bin/dev` and kill with `ctrl c`
* Run system tests with `bin/rails test:system`

## Course Notes
I've taken notes directly in the codebase. In the later chapters, I noted the chapter in the commit message. This is a breakdown of where things are happening in the codebase.

### CRUD First
As a general rule, we set up everything in the basic CRUD way first, then go back in to add hotwire and action cable technology. So expect to see a standard controller and standard erb files. We do this so that people who may have older browsers can still get the RESTful experience even if the snazzy hotwire experience does not work for them. The links are connected to CRUD routes and do hit those controller actions. Any time a link is inside a `turbo_frame_tag`, turbo intercepts the call in the controller and completes it via AJAX.

Since we need a little extra SPA-like functionality in our `create` and `destroy` actions (like adding or removing a record from a list of records inside a `<div>` on the index page), we also need to expand our controller `respond_to` block to include a `turbo_stream` format and provide a corresponding view file (ex: `app/views/quotes/create.turbo_stream.erb`) to outline those actions.

### Hotwire Frames
This is what gives you the snappy React-like behavior of having components appear/disappear on a single page. The `app/views/quotes/index.html.erb` has a "new" button which, when clicked, makes a form appear on the index page in the `turbo_frame_tag 'new_quote_form'` placeholder element. The form content is coming from the matching `turbo_frame_tag 'new_quote_form'` on the `app/views/quotes/new.html.erb` view. (Same, well, parallel, goes for the `edit` scenario.) Read the notes in the `app/controllers/quotes_controller.rb` and corresponding views for more details.

Following the code for `Quote` gives you the most simple example. Up a step from that is `LineItemDate` because it is a child of `Quote` and then the last level of complexity is the `LineItem` because it is a child of `LineItemDate`. At this most complex level, we need to use a nested dom_id to make sure turbo knows where exactly to locate nodes on the DOM. On the `app/views/quotes/show.html.erb` page, we display several `LineItemDate`s and nested within those components are several `LineItem`s. It is important to differentiate between the `LineItemDate` sections before appending a `ItemDate` into  one.

We used a little CSS magic to handle the "empty state" case of when there are no quotes on the index page. When empty, a prompt to "add a quote" is visible. When a single quote exists, the prompt is not visible. You'll see that in the `app/assets/stylesheets/components/_empty_state.scss`. If we chose not to use CSS, we'd have to write a lot of conditional logic in javascript to handle it. I wrote about it [here](https://lortza.github.io/2022/10/20/css-only-child.html).

### Action Cable Streaming
This is what gives you the functionality that updates content across all browsers. The `Quote` model houses the `broadcasts_to` statements. Always remember to restart the server if you are making changes to broadcast statements in the model or else weird stuff will happen.

Streaming is based on a stream name. By default, all users will see all content. :scream: In the case of a public chatroom where all `users` see all `messages`, that's what you want and a stream name of `"messages"` is perfect. But let's say that a `user` belongs to a `company` and we only want the `user` to see chat `messages` from their `company`. In this case, we'd name the messages stream in a scoped manner -- like a concatenation of the `dom_id` of the `company` object and the string `"messages"`. This ensures `users` only see `messages` relevant to their associated `company`.

In our app, we're talking about quotes, not messages, but we take the same scoped naming approach, using both `current_company` and `"quotes"`. So the model is broadcasting it (with `broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend`) and the whole `app/views/quotes/index.html.erb` view is subscribed to that stream with `<%= turbo_stream_from current_company, "quotes" >`. I think it is weird that the `quote` is associated to a `company` and not directly to a `user`, but it is what it is in this example.

### Beware of Magic
There is a lot of syntactic sugar available in these features, which is neat, but not explicit enough for me while I'm learning something new. For example, here is a shortcut line:
```ruby
broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
```
And here is all of the code it replaced:
```ruby
after_create_commit -> { broadcast_prepend_later_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }

after_update_commit -> { broadcast_replace_later_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }

after_destroy_commit -> { broadcast_remove_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
```
It's clean. I little _too_ clean. I made comments of all of the possible options in the codebase where I could.
