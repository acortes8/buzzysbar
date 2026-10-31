class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show ]
  def index
    @reviews = Review.all
  end

  def show
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @review.user = Current.user

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: "Review was successfully created." }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def review_params
    params.expect(review: [ :title, :body, :rating ])
  end

  def set_review
    @review = Review.find(params[:id])
  end
end
