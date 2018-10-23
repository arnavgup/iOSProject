class Student < ApplicationRecord

    has_many :enrollments

    validates_presence_of :first_name, :last_name

    scope :alphabetical, -> { order(:last_name, :first_name) }
    scope :active, -> {where(active: true)}
    scope :inactive, -> {where(active: false)}

    def name
        return first_name + " " + last_name
    end
end
