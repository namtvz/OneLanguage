class Channel < ActiveRecord::Base
  ACCESS_CODE_LENGTH = 32
  UUID_LENGTH = 10
  paginates_per 10

  extend FriendlyId

  # Relationships
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :translator, class_name: 'User', foreign_key: 'translator_id'
  belongs_to :partner, class_name: 'User', foreign_key: 'partner_id'

  # Validations
  validates :name, presence: true
  validates :owner_language, presence: true
  validates :partner_language, presence: true

  # Scopes
  scope :search, ->(current_user, term) {
    search_query_parts = ["(channels.name LIKE :term)"]
    search_query_parts << "(translators.name LIKE :term)"
    search_query_parts << "(owners.name LIKE :term)"
    search_query_parts << "(partners.name LIKE :term)"
    joins("LEFT JOIN users as owners ON owners.id = channels.owner_id").joins("LEFT JOIN users as partners ON partners.id = channels.partner_id").joins("LEFT JOIN users as translators ON translators.id = channels.translator_id").where([search_query_parts.join(' OR '), user_id: current_user.id, term: "%#{term}%"])
  }

  friendly_id :uuid

  # Callbacks
  before_create :ensure_partner_access_code, :ensure_translator_access_code, :ensure_uuid

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
    else
      nil
    end
  end

  def self.update_online_status
    self.find_each do
    end
  end

  # Instance methods
  def who_is? user
    case user.id
    when owner_id
      'owner'
    when translator_id
      'translator'
    else
      'partner'
    end
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

  def ensure_uuid
    loop do
      self.uuid = SecureRandom.hex UUID_LENGTH
      break unless Channel.find_by_uuid self.uuid
    end
  end
end