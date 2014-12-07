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
  after_create :listen_to_online_status

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
    self.find_each do |channel|
      channel.update_online_status
    end
  end

  def self.update_online_on_start
    self.find_each do |channel|
      PubnubService.instance.here_now(channel: channel.uuid) do |envelop|
        uuids = envelop.parsed_response['uuids']
        channel.owner_online = false
        channel.translator_online = false
        channel.partner_online = false
        channel.owner_online = uuids.include?(channel.owner_uuid)
        channel.translator_online = uuids.include?(channel.translator_uuid)
        channel.partner_online = uuids.include?(channel.partner_uuid)
        channel.save
      end
    end
  end


  # Instance methods
  def update_online_status
    PubnubService.instance.presence(channel: self.uuid) do |envelop|
      action = envelop.message['action']

      if action == 'join' || action == 'leave'
        is_online = action == 'join'
        channel = Channel.find_by_id self.id
        return if !channel

        case envelop.message['uuid']
          when channel.owner_uuid
            channel.owner_online = is_online
          when channel.translator_uuid
            channel.translator_online = is_online
          when channel.partner_uuid
            channel.partner_online = is_online
        end

        channel.save
      end
    end
  end

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

    loop do
      self.owner_uuid = SecureRandom.hex UUID_LENGTH
      break unless Channel.find_by_owner_uuid self.owner_uuid
    end

    loop do
      self.partner_uuid = SecureRandom.hex UUID_LENGTH
      break unless Channel.find_by_partner_uuid self.partner_uuid
    end

    loop do
      self.translator_uuid = SecureRandom.hex UUID_LENGTH
      break unless Channel.find_by_translator_uuid self.translator_uuid
    end
  end

  def listen_to_online_status
    self.update_online_status
    true
  end
end