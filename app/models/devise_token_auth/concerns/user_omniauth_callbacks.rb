module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :generate_uid

    validates :uid, presence: true
    validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }

    # only validate unique uids among email registration users
    validate :unique_uid_user, on: :create
    validate :unique_email_user, on: :create
  end

  module ClassMethods
    def uid
      loop do
        token = Devise.friendly_token
        break token unless to_adapter.find_first({uid: token})
      end
    end
  end

  protected

  # only validate unique email among users that registered by email
  def unique_uid_user
    if provider == 'email' && self.class.where(provider: 'email', uid: uid).count > 0
      errors.add(:uid, :taken)
    end
  end

  def unique_email_user
    if provider == 'email' && self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, :taken)
    end
  end

  private
  def generate_uid
    self.uid = self.class.uid unless self.uid.present?
  end
end
