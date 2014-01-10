module ApplicationHelper

	#Helper method for HTML creation of a link for removing a field.
	#@param name: link display name
	def link_to_remove_fields(name, f)
		#Hidden field is manipulated for setting the destruction of a field upon submission
    	f.hidden_field(:_destroy) + link_to_function(name, "formFieldsEditor().remove_fields(this)")
	end
  
  	#Helper method for HTML creation of a link for adding a field.
	#@param name: link display name 
	def link_to_add_fields(name, f, association)
		#instantiation of object of the association class and links it to the main object the form is creating
		#for the example of problems and test cases, it would create an instance of a test case and associate
		#it with the new problem from the form.
		new_object = f.object.class.reflect_on_association(association).klass.new
		
		#association form HTML
		fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
			render("form_" + association.to_s.singularize + "_fields", :f => builder)
		end

		#create link for adding fields adn return it
		link_to_function(name, "formFieldsEditor().add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
	end
	
	private
		#Action to take if attempt to redirect to the last page but there isn't one
		#made from a HTTP request.
		def lacks_back
			redirect_to root_url
		end


end
