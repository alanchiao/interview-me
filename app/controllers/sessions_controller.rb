class SessionsController < ApplicationController

	# POST /sessions - for taking the record created by the "new"
	# action and creating a cookie from it.
	def create
		user = User.find_by(username: params[:session][:username])
	    if user && user.authenticate(params[:session][:password])
	    	sign_in user
	    else
	    	flash.now[:danger] = 'Wrong username/password combination'
	    end
	  respond_to do |format|
      format.html
      format.js
    end
	end

	# DELETE /signout - for deleting the cookie and logging out
	def destroy
		sign_out
		redirect_to root_url
  	end

end
