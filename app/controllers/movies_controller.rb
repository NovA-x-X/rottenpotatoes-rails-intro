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
    @all_ratings ||= [] # initializes rating array
    Movie.all.order(:rating).each do |m| #orders movies by rating so the checkboxes will be in order
      @all_ratings << m.rating unless @all_ratings.include? m.rating # adds all unique ratings to array
    end
    if params[:sort_by].nil? && params[:ratings].nil? && session[:sort_by].nil? && session[:ratings].nil? # if the app was just opened
      @movies = Movie.all # show all movies, unsorted
    elsif !params[:sort_by].nil? || !params[:ratings].nil? # if a tab is clicked or the checkboxes are changed
      session[:sort_by] = params[:sort_by] unless params[:sort_by].nil? # store the new tab is session unless it wasn't changed
      session[:ratings] = params[:ratings] unless params[:ratings].nil? # store the checkboxes is session unless they weren't changed
      if params[:sort_by].nil? && !params[:ratings].nil? # if no tab is clicked but checkboxes were changed
        @movies = Movie.all.where(rating: session[:ratings].keys) # filter movies by rating
      elsif !params[:sort_by].nil? && params[:ratings].nil? # if checkboxes weren't changed but a tab was clicked
        @movies = Movie.all.order(session[:sort_by])
        @movies = Movie.all.order(session[:sort_by]).where(rating: session[:ratings].keys) unless session[:ratings].nil? # sort movies by tab
      elsif !params[:sort_by].nil? && !params[:ratings].nil? # if a tab is clicked and checkboxes are changed
        @movies = Movie.all.order(session[:sort_by]).where(rating: session[:ratings].keys) # sort all of the movies and filter by rating
      end
    elsif params[:sort_by].nil? && params[:ratings].nil? && (!session[:sort_by].nil? || !session[:ratings].nil?) # if no changes are made but there were past changes
      if session[:sort_by].nil? && !session[:ratings].nil? # if no tab has ever been clicked but checkboxes were changed
        @movies = Movie.all.where(rating: session[:ratings].keys) # filter movies by rating
        flash.keep
        redirect_to movies_path(:sort_by => session[:sort_by], :ratings => session[:ratings]) #
      elsif !session[:sort_by].nil? && session[:ratings].nil? # if checkboxes weren't ever changed but a tab was clicked
        @movies = Movie.all.order(session[:sort_by]) # sort movies by tab
        flash.keep
        redirect_to movies_path(:sort_by => session[:sort_by], :ratings => session[:ratings])
      elsif !session[:sort_by].nil? && !session[:ratings].nil? # if a tab was once clicked and checkboxes have been changed
        @movies = Movie.all.order(session[:sort_by]).where(rating: session[:ratings].keys) # sort all of the movies and filter by rating
        flash.keep
        redirect_to movies_path(:sort_by => session[:sort_by], :ratings => session[:ratings])
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