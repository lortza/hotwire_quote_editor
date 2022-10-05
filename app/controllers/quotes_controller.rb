class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def index
    # Keep the order of the quotes consistent even if we refresh the page.
    @quotes = Quote.ordered
  end

  def show
  end

  def new
    # When we route to this action, the `new` view is accessed and only the html
    # with the matching turbo_frame_tag id `new_form` will be rendered inside the
    # turbo_frame_tag('new_form') on the index.
    @quote = Quote.new


    When clicking on the "New quote" link, the click will be intercepted by Turbo.
    Turbo knows it has to interact with the frame of id new_quote thanks to the attribute data-turbo-frame on the "New quote" link.
    The request is sent in AJAX, and our server will render the Quotes#new page with a frame with id new_quote.
    When the browser receives the HTML, Turbo will extract the frame with the id of new_quote from the Quotes#new page and replace the empty frame with the same id on the Quotes#index page!

  end

  def create
    # When clicking on the "Create Quote" button, the form submission is intercepted by Turbo.
    @quote = Quote.new(quote_params)

    # The form is wrapped in a frame with id `new_form`, so Turbo knows it only needs to replace this frame.
    if @quote.save
      respond_to do |format|
        format.html { redirect_to quotes_path, notice: "Quote was successfully created." }
        # In order to get SPA-like behavior on a create, we need to include support for the
        # turbo_stream response format and then make a corresponding view for it. This will
        # allow us to prepend the new content to the target turbo_frame. see:
        # app/views/quotes/destroy.turbo_stream.erb
        format.turbo_stream
      end
    else
      # The server receives the invalid params in the QuotesController#create action and renders
      # the Quotes#new view with the form containing errors.
      render :new, status: :unprocessable_entity
      # When the browser receives the response with the status: :unprocessable_entity, it replaces
      # the frame with id new_quote with the new one that contains errors.
    end
  end

  def edit
    # When we route to this action from the `_quote` partial on the index page, the `edit` view is
    # accessed and only the html with the matching turbo_frame_tag dom_id from the `@quote` object
    # will be rendered inside the turbo_frame_tag(@quote) in the `_quote` partial.
  end

  def update
    # When clicking on the "Update quote" button, Turbo intercepts the submit event as the form
    # is nested within a Turbo Frame.
    if @quote.update(quote_params)
      # 2. The form submission is valid on the controller side, so the controller redirects to the
      # Quotes#index page.
      redirect_to quotes_path, notice: "Quote was successfully updated."
      # 3. The updated Quotes#index page contains a Turbo Frame of the same id that contains a card
      # with the updated quote name.
      # 4. Turbo replaces the frame's content containing the form with the frame's content containing
      # the updated quote card.
    else
      # 2. The form submission is invalid, so the controller renders the app/quotes/edit.html.erb view
      # with the errors on the form.
      render :edit, status: :unprocessable_entity
      # 3. Thanks to the 422 response status added by the status: :unprocessable_entity option, Turbo
      # knows it has to replace the content of the Turbo Frame with the new one containing errors.
      # 4. The errors are successfully displayed on the page.
    end
  end

  def destroy
    # Remove the record from the database
    @quote.destroy

    respond_to do |format|
      format.html { redirect_to quotes_path, notice: "Quote was successfully destroyed." }
      # Remove the component from the DOM.
      # In order to get SPA-like behavior on a delete, we need to include support for the
      # turbo_stream response format and then make a corresponding view for it. see:
      # app/views/quotes/destroy.turbo_stream.erb
      format.turbo_stream
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end
end
