# Mashov Api

## ...What is this thing?

The [Mashov (students)](https://www.mashov.info/) API - for flutter.

## Where do I get started?
First of all, get yourself a nice `Api Controller` to your code:
```dart
var controller = MashovApi.getController();
```
Next, get the list of schools:
```dart
var schoolsResult = await controller.getSchools();
if(schoolsResult.isSucess) {
  var schools = schoolsResult.value;
}
```
Now, you can pick your school and log in with it:
```dart
await controller.login(mySchool, myId, mySecretPassword, year)
```
Once you log in successfully...
You can do whatever you want!
```dart
controller.getGrades();
controller.getBehaveEvents();
....
```
### ...Are there any docs?
Well, the code is pretty well documented. If you have any issues, post a new issue.
