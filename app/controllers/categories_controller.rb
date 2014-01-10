class CategoriesController < ApplicationController

    # GET /categories/1
    # Receives AJAX call and responds with calling for display of a category problems listing
    def show
        @category = Category.find_by_id(params[:id])
        raise ActionController::RoutingError.new('Not Found') unless @category
        respond_to do |format|
            format.js
        end
    end
end
