## 0.0.1
* Initial commit
## 0.0.2
* Fixed unhandled exception on login
## 0.0.3
* Added Bagrut grades and Hatamot APIs.
## 0.0.4
* Added Api enum and Data Processor to Api Controller.
## 0.0.5
* Put all models file in one file, and by doing this exported another two models that were not exported in version 0.0.4
## 0.0.6
* Added statusCode to Login, and some nice getters such as isUnauthorized.
## 0.0.7
* Moved status Code from Login to Result, added isOk getter, added status code to all requests.
## 0.0.8
* Fixed Api controller passing Future<Result<E>> to data processor instead of E.
## 0.0.9
* Added raw data processor, allowing the processing of the JSON data itself, and not the parsed objects.
* Removed Utils.date as it is pretty much useless.
## 0.0.10
* Updated timetable API
## 0.0.11 - 0.0.13
* Messed up and fixed students API
## 0.1.0
* Fixed messages count and get message not working because of implicit type conversions
## 0.3.0
* Moved bagrut grades into a bigger model called Bagrut which includes time, date and room too.
  Bagrut grades will no longer pass through raw data processor, as they require two different requests.
  They will still pass through the data processor.
* Added a changelog.
## 0.3.0+1
* Updated API version
## 0.3.0+2
* Added Hatamot Bagrut.
## 0.3.0+3
* Added Bells.
## 0.4.0
Breaking changes - Lesson is now combined with Bell.
## 0.5.0
Fixed contacts API