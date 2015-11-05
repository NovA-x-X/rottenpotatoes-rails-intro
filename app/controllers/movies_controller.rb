class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.pluck(:rating).uniq
    @checked_boxes = Hash.new(true)
    @all_ratings.each{|r| @checked_boxes[r] = true}

    id = params[:id]

    if id == "title_header"
      @movies = Movie.all.order(:title)
      @title_class = "hilite";
      session[:id] = id
      session.delete(:ratings_)
    elsif id == "release_date_header"
      @movies = Movie.all.order(:release_date)
      @release_class = "hilite"
      session[:id] = id
      session.delete(:ratings_)
    else
      if params[:ratings_].present?
        session.delete(:id)
      end
      if session[:id].present?
        if session[:id] == "title_header"
          @movies = Movie.all.order(:title)
          @title_class = "hilite"
        elsif session[:id] == "release_date_header"
          @movies = Movie.all.order(:release_date)
          @release_class = "hilite"
        end
        flash.keep
        redirect_to :id => session[:id]
      else
        @movies = Movie.all
      end
    end

    if params[:ratings_].present?
      rs = params[:ratings_].keys
      if rs.empty?
        if session[:ratings_].present?
          rs = session[:ratings_].keys
          @checked_boxes = params[:ratings_]
        end
      else
        @checked_boxes = params[:ratings_]
      end
      @movies = Movie.where(rating: rs)
      session[:ratings_] = @checked_boxes
    else
      if session[:ratings_].present?
        rs = session[:ratings_].keys
        @checked_boxes = session[:ratings_]
        @movies = Movie.where(rating: rs)
        flash.keep
        redirect_to :ratings_ => session[:ratings_]
      end
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end