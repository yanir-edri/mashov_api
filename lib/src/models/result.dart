class Result<E> {
  dynamic exception;
  E value;

  Result({this.exception, this.value});

  //Returns true if value can be used, false otherwise.
  bool get isSuccess => exception == null && value != null;
}
