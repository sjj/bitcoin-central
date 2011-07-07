class Yubikey < ActiveRecord::Base
  attr_accessor :otp
  attr_accessible :otp

  belongs_to :user

  before_validation :set_key_id

  validates :key_id,
    :presence => true,
    :uniqueness => true

  validates :user,
    :presence => true
  
  def valid_otp?
    Yubico::Client.instance.verify_otp(otp)
  end

  def to_label
    "Key : #{key_id}"
  end

  protected

  def set_key_id
    unless key_id
      if valid_otp?
        self.key_id = otp[0, 12]
      else
        errors[:base] << I18n.t("errors.messages.invalid_otp")
      end
    end
  end
end
