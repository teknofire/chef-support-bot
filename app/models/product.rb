class Product < ApplicationRecord
  has_many :persons, dependent: :nullify

  validates :name, uniqueness: true
end
