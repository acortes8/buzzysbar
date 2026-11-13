# Books are added from the recipe form, by title; these pages list them and
# their recipes, and let a book's title or author be fixed.
class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books
  def index
    @books = Current.logbook.books.includes(:recipes).order(:title)
  end

  # GET /books/1
  def show
  end

  # GET /books/1/edit
  def edit
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(params.expect(book: [ :title, :author ]))
      redirect_to @book, notice: "Book was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    if @book.destroy
      redirect_to books_path, notice: "Book was successfully destroyed.", status: :see_other
    else
      redirect_to @book, alert: @book.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_book
      @book = Current.logbook.books.find(params.expect(:id))
    end
end
