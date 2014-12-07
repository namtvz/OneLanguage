class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates :name, presence: true

  # Relationships
  has_many :owner_channels, class_name: 'Channel', foreign_key: 'owner_id'
  has_many :translator_channels, class_name: 'Channel', foreign_key: 'translator_id'
  has_many :partner_channels, class_name: 'Channel', foreign_key: 'partner_id'

  has_many :identities, dependent: :destroy

  has_attached_file :avatar, :styles => {small: "50x50>"},
    default_url: "no-avatar.png"

  validates_attachment_content_type :avatar, content_type: ["image/png", "image/jpeg", "image/gif"]

  has_many :languages

  # Class methods
  def self.find_for_oauth(auth, signed_in_resource = nil)
    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)
    user = identity.user ? identity.user : signed_in_resource

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email
      # If the email has not been verified by the provider we will assign the
      # TEMP_EMAIL and get the user to verify it via UsersController.add_email
      # email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      # email = auth.info.email if email_is_verified
      email = auth.info.email #|| auth.uid+"@twitter.com"
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          email: email,
          password: Devise.friendly_token[0,20]
        )
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  # Instance methods
  def translator?
    self.is_translator
  end

  def get_my_channels
    if self.translator?
      self.translator_channels
    else
      Channel.where("owner_id = :user_id OR partner_id = :user_id", user_id: self.id)
    end
  end

  def language_names
    names = languages.pluck(:name)
    if names.empty?
      ""
    else
      names.join(", ")
    end
  end

  def avatar_url
    DEFAULT_IMAGE_URL
  end
end
