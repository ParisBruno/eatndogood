class Agreement < ApplicationRecord
  belongs_to :style
  belongs_to :user, optional: true
end
