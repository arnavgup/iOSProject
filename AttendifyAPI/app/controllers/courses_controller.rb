class CoursesController < ApplicationController
  swagger_controller :course, "Course Management"

    swagger_api :index do
        summary "Fetches all courses"
        notes "This lists all the courses"
    end

    swagger_api :show do
        summary "Shows one course"
        param :path, :id, :integer, :required, "course ID"
        notes "This lists details of one course"
        response :not_found
    end

    swagger_api :create do
        summary "Creates a new course"
        param :form, :professor_id, :integer, :required, "Professor ID"
        param :form, :class_number, :string, :required, "Class Number"
        param :form, :semester_year, :string, :required, "Semester Year"
        param :form, :active, :boolean, :required, "Active"
        response :not_acceptable
    end

    swagger_api :update do
        summary "Updates an existing course"
        param :form, :professor_id, :integer, :required, "Professor ID"
        param :form, :class_number, :string, :required, "Class Number"
        param :form, :semester_year, :string, :required, "Semester Year"
        param :form, :active, :boolean, :required, "Active"
        response :not_found
        response :not_acceptable
    end


    before_action :set_course, only: [:show, :update, :destroy]

    # GET /courses
    def index
        @courses = Course.all

        render json: @courses
    end

    # GET /courses/1
    def show
        render json: @course
    end

    # POST /courses
    def create
        @course = Course.new(course_params)

        if @course.save
          render json: @course, status: :created, location: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /courses/1
    def update
        if @course.update(course_params)
            render json: @course
        else
            render json: @course.errors, status: :unprocessable_entity
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
        @course = Course.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_params
        params.permit(:professor_id, :class_Number, :semester_year, :active)
    end
end
