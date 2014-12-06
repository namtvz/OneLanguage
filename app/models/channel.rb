class Channel < ActiveRecord::Base
  ACCESS_CODE_LENGTH = 32
  paginates_per 1

  # Relationships
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :translator, class_name: 'User', foreign_key: 'translator_id'
  belongs_to :partner, class_name: 'User', foreign_key: 'partner_id'

  # Validations
  validates :name, presence: true
  validates :owner_language, presence: true
  validates :partner_language, presence: true

  # Scopes
  default_scope -> { order(:created_at) }

  # Callbacks
  before_create :ensure_partner_access_code, :ensure_translator_access_code

  # Class methods
  def self.data_for_token token
    channel = self.where("partner_access_code = :token OR translator_access_code = :token", token: token).first
    if channel
      if channel.partner_access_code == token
        {
          channel: channel,
          role: 'partner'
        }
      elsif channel.translator_access_code == token
        {
          channel: channel,
          role: 'translator'
        }
      end
    end

    return nil
  end

  private
  def ensure_partner_access_code
    loop do
      self.partner_access_code = SecureRandom.hex ACCESS_CODE_LENGTH
      break unless Channel.data_for_token self.partner_access_code
    end
  end

  def ensure_translator_access_code
    loop do
      self.translator_access_code = SecureRandom.hex ACCESS_CODE_LENGTH
      break unless Channel.data_for_token self.translator_access_code
    end
  end
end