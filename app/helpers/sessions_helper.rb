module SessionsHelper

	# Signs user in by creating remember token and updating cookie
	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

	# Return if site visitor is signed in
	def signed_in?
		!current_user.nil?
	end

	# Logs user out of site
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	# Returns is user the current user
	def current_user=(user)
		@current_user = user
	end

	# Returns User Object for user logged in
	def current_user
	    remember_token = User.encrypt(cookies[:remember_token])
	    @current_user ||= User.find_by(remember_token: remember_token)
	end

end
