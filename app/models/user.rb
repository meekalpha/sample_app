class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy

	attr_accessor 	:remember_token,
					:activation_token,
					:reset_token 

	before_save 	:downcase_email
	before_create 	:create_activation_digest

	validates :name, presence: true
	validates :name, length: { maximum: 50 }

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true
	validates :email, length: { maximum: 255 }
	validates :email, format: { with: VALID_EMAIL_REGEX }
	validates :email, uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end	

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end												

	def activate
		update_attributes(activated: true, activated_at: Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attributes(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
		Micropost.where("user_id = ?", id)
	end

	private
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end

		def downcase_email
			self.email.downcase!
		end
	class << self
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? 	BCrypt::Engine::MIN_COST :
																BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

		def new_token
			SecureRandom.urlsafe_base64
		end	
	end

end