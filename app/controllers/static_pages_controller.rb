class StaticPagesController < ApplicationController

  before_action :requireAdmin, only: [:permissions, :manage_content_creators, :manage_admins]

  # GET /
  def home
  end

  # GET /permissions
  def permissions
  end

  # Give user content creator permissions if exists and user doe not already have permission
  def manage_content_creators
    # Get username for attempt to add new content creator
    @newcc = User.find_by_username(params[:'new-cc'])

    #Attempt to add content creator
    if @newcc != nil
      if @newcc.is_content_creator? || @newcc.is_admin?
        flash.now[:danger] = @newcc.first_name + " already has content creation permission"
      else
        @newcc.make_content_creator()
        flash.now[:success] = @newcc.first_name + " is now a content creator"
      end
    else
      flash.now[:danger] = params[:'new-cc'] + " is not a valid username. Unable to add " + params[:'new-cc'] + " as a content creator. "
    end
    respond_to do |format|
      format.html { redirect_to({controller: 'static_pages', action: 'permissions'}) }
      format.js
    end
  end

  # Give user admin permissions if exists and user doe not already have permission
  def manage_admins
    # Get username for attempt to add new admin
    @newadmin = User.find_by_username(params[:'new-admin'])

    # Attempt to add admin
    if @newadmin != nil
      if @newadmin.is_admin?
        flash.now[:danger] = @newadmin.first_name + " already is an admin. "
      else
        @newadmin.make_admin()
        flash.now[:success] = @newadmin.first_name + " is now an admin"
      end
    else
      flash.now[:danger] = params[:'new-admin'] + " is not a valid username. Unable to add " + params[:'new-admin'] + " as a admin. "
    end
    respond_to do |format|
      format.html { redirect_to({controller: 'static_pages', action: 'permissions'}) }
      format.js
    end
  end

end
