class UsersController < ApplicationController

	# GET /users/1
	def show
		@user = User.find(params[:id])
	end

	# GET /signup
	def new
		@user = User.new
	end

	# POST /users - for taking the record created by the "new" action and creating/storing a user
	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			flash[:success] = "Successful Registration"
			redirect_to problems_url
	    else
	      render 'new'
	    end
	end

	# GET /analytics/1
	def analytics
		@analytics = User.find(params[:id]).analytics
		respond_to do |format|
			format.html
			format.json { render json: @analytics}
		end
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def user_params
			params.require(:user).permit(:username, :first_name, :last_name, :password, :password_confirmation)
		end

end
