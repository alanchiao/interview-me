class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.\
  protect_from_forgery with: :exception

  include ApplicationHelper
  include SessionsHelper

  def requireAdmin
    unless signed_in? && current_user.is_admin?
        flash[:error] =  "You must be an admin to access this page."
        redirect_to root_url
    end
  end

  private
  		#Check on if user is logged in. Otherwise, redirect.
		#Based on nature of application, it should apply to most controller
		#functions except those of show.
		def require_login
			redirect_to root_url, notice: "Please sign in." unless signed_in? #update to new_session_url
		end

		#Check on if user has at least the privileges of a content_creator.
		#Otherwise, redirect to where they came from.
		def require_content_creator
			redirect_to :back, notice: "Lacks privileges of content creator" unless @current_user.is_content_creator? or @current_user.is_admin?
			rescue ActionController::RedirectBackError
				lacks_back
		end

		#Check on if user has at least admin privileges.
		#Otherwise, redirect to where they came from.
		def require_admin
			redirect_to :back, notice: "Is not an admin" unless @current_user.is_admin?
			rescue ActionController::RedirectBackError
				lacks_back
		end
end
