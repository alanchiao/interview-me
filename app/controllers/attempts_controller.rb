class AttemptsController < ApplicationController

    before_action :require_login, only: [:autosave]

    # Receives AJAX request to update user's attempt at a solution
    def autosave
        Attempt.autosave(current_user.id, params['problemID'], params['text'])
        respond_to do |format|
           format.json { render text: { success: true }.to_json }
        end
    end
end