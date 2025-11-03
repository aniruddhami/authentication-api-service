class User < ApplicationRecord
  has_secure_password

  # Validations for signup constraints
  VALID_USER_ID_REGEX = /\A[A-Za-z0-9]+\z/
  VALID_ASCII_NO_SPACE_REGEX = /\A[\x21-\x7E]+\z/
  NO_CONTROL_CODE_REGEX = /\A[^\p{Cntrl}]*\z/

  validates :user_id,
            presence: true,
            length: { in: 6..20 },
            format: { with: VALID_USER_ID_REGEX }

  validates :password,
            presence: true,
            length: { in: 8..20 },
            format: { with: VALID_ASCII_NO_SPACE_REGEX },
            on: :create

  validates :nickname,
            allow_nil: true,
            length: { maximum: 30 },
            format: { with: NO_CONTROL_CODE_REGEX }

  validates :comment,
            allow_nil: true,
            length: { maximum: 100 },
            format: { with: NO_CONTROL_CODE_REGEX }
end
