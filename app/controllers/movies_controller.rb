class MoviesController < ApplicationController

  def initialize
    @all_ratings = Movie.all_ratings
    super
  end
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    checked_ratings = params[:ratings] || session[:ratings]
    sorting = params[:sort] || session[:sort]
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sorting
      session[:ratings] = checked_ratings
      flash.keep
      redirect_to movies_path(:sort => sorting, :ratings => checked_ratings)
    end
    
    if checked_ratings
      @selected_ratings = checked_ratings.keys
    else
      @selected_ratings = @all_ratings
    end
    
    if params[:sort].nil?
      @movies = Movie.where(rating: @selected_ratings)
    else
      if sorting == 'release_date'
        @movies = Movie.where(rating: @selected_ratings).order(:release_date)
      elsif sorting == 'title'
        @movies = Movie.where(rating: @selected_ratings).order(:title)
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