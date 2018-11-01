from flask import Flask, request, jsonify
from flask_uploads import UploadSet, IMAGES, configure_uploads
from flask import make_response
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import turicreate as tc
import sys
from queue import Queue
import os
import logging
from flask import send_from_directory
import threading
from marshmallow import fields
from marshmallow import post_load
import os
import boto3
S3_BUCKET = "gyao.iosproject.faceimages"
S3_KEY = os.environ.get("S3_ACCESS_KEY")
S3_SECRET = os.environ.get("S3_SECRET_ACCESS_KEY")
s3 = boto3.client('s3')
bucket_name = S3_BUCKET


app = Flask(__name__)
if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host='0.0.0.0', port=80, debug=True)
    print("asdf")

# configure logging
logging.basicConfig(level=logging.DEBUG,
                    format='[%(levelname)s] - %(threadName)-10s : %(message)s')

# configure images destination folder
app.config['UPLOADED_IMAGES_DEST'] = './images'
images = UploadSet('images', IMAGES)
configure_uploads(app, images)

# configure sqlite database
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir,
                                                                    'facerecognition.sqlite')
db = SQLAlchemy(app)
ma = Marshmallow(app)


# model/users is a many to many relationship,  that means there's a third
# table containing user id and model id
students_models = db.Table('students_models',
                           db.Column("student_id", db.String(300),
                                     db.ForeignKey('student.id')),
                           db.Column("model_id", db.Integer,
                                     db.ForeignKey('model.version'))
                           )
# model table


class Model(db.Model):
    version = db.Column(db.Integer, primary_key=True)
    url = db.Column(db.String(100))
    students = db.relationship('Student', secondary=students_models)

# user table
#name, id, position


class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    andrewid = db.Column(db.String(300))
    fullname = db.Column(db.String(300))
    classid = db.Column(db.Integer)

    def __init__(self, andrewid, fullname, classid):
        self.andrewid = andrewid
        self.fullname = fullname
        self.classid = classid

# user schema


class StudentSchema(ma.Schema):
    class Meta:
        fields = ('id', 'andrewid', 'fullname', 'classid')

# model schema


class ModelSchema(ma.Schema):
    version = fields.Int()
    url = fields.Method("add_host_to_url")
    students = ma.Nested(StudentSchema, many=True)
    # this is necessary because we need to append the current host to the model url

    def add_host_to_url(self, obj):
        return request.host_url + obj.url


# initialize everything
student_schema = StudentSchema()
students_schema = StudentSchema(many=True)
model_schema = ModelSchema()
models_schema = ModelSchema(many=True)
db.create_all()


# error handlers
@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'not found'}), 404)


@app.errorhandler(400)
def not_found(error):
    return make_response(jsonify({'error': 'bad request'}), 400)


# register user
@app.route("/student/register", methods=['POST'])
def register_user():
    if not request.form or not 'andrewid' in request.form:
        return make_response(jsonify({'status': 'failed', 'error': 'bad request', 'message:': 'Andrew ID is required'}), 400)
    else:
        andrewid = request.form['andrewid']
        fullname = request.form['name']
        classid = request.form['classid']
        newStudent = Student(andrewid, fullname, classid)
        db.session.add(newStudent)
        db.session.commit()
        if 'photos' in request.files:
            uploaded_images = request.files.getlist('photos')
            save_images_to_folder(uploaded_images, newStudent)
        return jsonify({'status': 'success', 'user':  student_schema.dump(newStudent).data})

# function to save images to image directory


def save_images_to_folder(images_to_save, student):
    fileCount = 0
    for a_file in images_to_save:
        fileCount += 1
        # save images to images folder using user id as a subfolder name
        images.save(a_file, str(student.andrewid),
                    "image_" + str(fileCount) + '.')

        # upload image to respective folder in bucket
        filename = "images/" + str(student.andrewid) + "/" + "image_" + str(fileCount) + ".jpg"
        print("filename: " + filename)
        s3.upload_file(filename, bucket_name, filename)


    # get the last trained model
    model = Model.query.order_by(Model.version.desc()).first()
    if model is not None:
        # increment the version
        queue.put(model.version + 1)
    else:
        # create first version
        queue.put(1)


# serve models
@app.route('/models/')
def download(filename):
    return send_from_directory('models', filename, as_attachment=True)


def train_model():
    while True:
        # get the next version
        version = queue.get()
        logging.debug('loading images')
        data = tc.image_analysis.load_images('images', with_path=True)

        # From the path-name, create a label column
        data['label'] = data['path'].apply(lambda path: path.split('/')[-2])

        # use the model version to construct a filename
        filename = 'Faces_v' + str(version)
        mlmodel_filename = filename + '.mlmodel'
        models_folder = 'models/'

        # Save the data for future use
        data.save(models_folder + filename + '.sframe')

        result_data = tc.SFrame(models_folder + filename + '.sframe')
        train_data = result_data.random_split(0.8)

        # the next line starts the training process
        model = tc.image_classifier.create(
            train_data[0], target='label', model='resnet-50', verbose=True)

        db.session.commit()
        logging.debug('saving model')
        model.save(models_folder + filename + '.model')
        logging.debug('saving coremlmodel')
        model.export_coreml(models_folder + mlmodel_filename)

        # save model data in database
        modelData = Model()
        modelData.url = models_folder + mlmodel_filename
        classes = model.classes
        for andrewid in classes:
            student = Student.query.get(andrewid)
            if student is not None:
                modelData.students.append(student)
        db.session.add(modelData)
        db.session.commit()
        logging.debug('done creating model')
        # mark this task as done
        queue.task_done()


# configure queue for training models
queue = Queue(maxsize=100)
thread = threading.Thread(target=train_model, name='TrainingDaemon')
thread.setDaemon(False)
thread.start()
