class User < ActiveRecord::Base

	has_secure_password
	has_many :problems
	has_many :attempts
	has_many :comments
	has_many :votes
	validates :username, presence: true, length: { maximum: 20 }, uniqueness: true
	validates :first_name, presence: true, length: { maximum: 40 }
	validates :last_name, presence: true, length: { maximum: 40 }

	before_create :create_remember_token

	# Return a capitalized first name
	def first_name
		read_attribute(:first_name).try(:titleize)
	end

	# Return a capitalized last name
	def last_name
		read_attribute(:last_name).try(:titleize)
	end

	# Returns true if this user has permission to write problems
	def is_content_creator?
		return self.usertype == "content_creator"
	end

	# Change usertype so that user can create problems
	def make_content_creator
		self.usertype = "content_creator"
		self.save
	end

	# Return listing of all content creators
	def User.get_content_creators
		return User.where(usertype: :content_creator)
	end

	# Returns true if this user is a site administrator
	def is_admin?
		return self.usertype == "admin"
	end

	# Change usertype so user has admin privelages
	def make_admin
		self.usertype = "admin"
		self.save
	end

	# Return listing of all admins
	def User.get_admins
		return User.where(usertype: :admin)
	end

	# Return hash of problems users attempted in each category with the total number of problems in that category
	# category : { problems attempted, total problems in category }
	def analytics
		completions = {}
		Category.all.each do |c|
			completions[c.name] = [0, c.problems.count]
		end
		self.attempts.each do |a|
			completions[Category.find_by_id(a.problem.category_id).name][0] += 1
		end
		return completions
	end

	# Get the user's attempt for a particular problem
	def get_attempt(problem)
		if problem
			return self.attempts.where(problem_id: problem.id).first
		end
	end

	# Return hash of data associated with problems that user has attempted
	# problem name : { problem id, category name, question, problem first attempted at, problem last attempted at }
	def get_attempts_data
		data = {}
		self.attempts.each do |a|
			p = a.problem
			data[a.problem.title] = [p.id, p.category.name, p.question, a.created_at, a.updated_at]
		end
		return data
	end

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end

end
