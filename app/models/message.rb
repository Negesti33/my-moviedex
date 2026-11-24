class Message < ApplicationRecord
  ROLES = ["user", "assistant"].freeze

  belongs_to :chat

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true
  # allow_blank: false, length: { minimum: 1 },
end
