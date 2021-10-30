# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  remember_token         :string
#  reset_password_token   :string
#  time_zone              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  has_secure_password #adds authenticate method, etc.

  has_many :workouts, dependent: :destroy
  has_many :routes, dependent: :destroy
  has_many :workout_types, dependent: :destroy
  has_many :workout_routes, dependent: :destroy
  has_many :additional_data_types, dependent: :destroy
  has_many :additional_data_type_options, dependent: :destroy
  has_many :additional_data_type_values, dependent: :destroy

  before_save { |user| user.email.downcase! }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100}, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}

  validates :password, :presence =>true, :confirmation => true, :length => { :within => 6..40 }, :on => :create
  validates :password, :confirmation => true, :length => { :within => 6..40 }, :on => :update_password

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.hours_to_reset_password
    1
  end

  def User.hours_to_do_first_login
    24
  end

  def generate_password_token!
    self.reset_password_token = generate_pw_token
    self.password_reset_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    if (self.created_at + User.hours_to_do_first_login.hours) > Time.now.utc
      #new user gets hours_to_do_first_login to do their password reset
      true
    else
      #established user gets hours_to_reset_password
      (self.password_reset_sent_at + User.hours_to_reset_password.hours) > Time.now.utc
    end
  end

  private
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def generate_pw_token
    SecureRandom.hex(10)
  end


end
