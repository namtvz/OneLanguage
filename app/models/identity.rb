class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth(auth)
    identity = where(provider: auth.provider, uid: auth.uid).first
    identity = create(uid: auth.uid, provider: auth.provider) if identity.nil?
    identity
  end
end
