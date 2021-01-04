from flask import Flask
from flask_restful import Resource, Api
import platform

app = Flask(__name__)
api = Api(app)

class HelloWorld(Resource):
    def get(self):
        result = "World"
        return {
            'Hello':result
        }

class Greetings(Resource):
    def get(self):
        result = "Hello World from " + platform.node()
        return {
            'Greetings':result
        }

class Square(Resource):
    def get(self,number):
        square = int(number)
        square *= square
        return {
            'Number':number,
            'Square':square
        }

api.add_resource(HelloWorld,'/')
api.add_resource(Greetings,'/greetings')
api.add_resource(Square,'/square/<number>')

if __name__ == "__main__":
    app.run(host='0.0.0.0',port='8080')
