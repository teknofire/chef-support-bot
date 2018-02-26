class Product < ApplicationRecord
  has_many :persons, dependent: :nullify
end
