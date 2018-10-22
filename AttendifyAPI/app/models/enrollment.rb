class Enrollment < ApplicationRecord

    belongs_to :class
    belongs_to :student
end
