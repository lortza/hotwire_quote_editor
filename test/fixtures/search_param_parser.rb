# frozen_string_literal: true

module SearchParamParser
  def self.parse_movie_params(params)
    output = {
      actor_name: params[:actor_name],
      year: nil,
      year_display: nil,
      timeframe: params[:timeframe],
      genre: params[:genre],
      company: params[:company],
      mpaa_rating: params[:mpaa_rating],
      page: (params[:page].presence || 1),
      sort_by: (params[:sort_by].presence || 'popularity')
    }

    output[:year] = params[:year].presence || params&.dig(:date)&.dig(:year).presence
    output.select { |_k, v| v.present? }
  end

  def self.parse_movie_params_for_display(params)
    output = {}
    output[:actor_name_display] = "#{params[:actor_name].titlecase} movies" if params[:actor_name].present?
    output[:mpaa_rating_display] = "Rated #{params[:mpaa_rating]}" if params[:mpaa_rating].present?

    if params[:genre].present?
      genres = MovieDataService::GENRES.to_h
      genre_selected = genres.key(params[:genre].to_i)
      output[:genre_display] = "#{genre_selected} movies"
    end

    year = params[:year].presence || params&.dig(:date)&.dig(:year).presence
    if year.present?
      output[:year_display] =
        case params[:timeframe]
        when 'before' then "before #{year}"
        when 'after' then "after #{year}"
        else "from #{year}"
        end
    end

    if params[:sort_by].present?
      sort_options = MovieDataService::SORT_BY.to_h
      sort_key = sort_options.key(params[:sort_by])
      output[:sort_display] = "sorted by #{sort_key}"
    end

    output
      .select { |_k, v| v.present? }
      .values
      .join(', ')
  end
end
