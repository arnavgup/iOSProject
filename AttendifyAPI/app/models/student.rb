class Student < ApplicationRecord

    has_many :enrollments
    has_many :photos

    validates_presence_of :first_name, :last_name

    scope :alphabetical, -> { order(:last_name, :first_name) }
    scope :active, -> {where(active: true)}

    def name
        return first_name + " " + last_name
    end
end
