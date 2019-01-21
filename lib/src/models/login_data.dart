class LoginData {
  LoginData(
      {this.sessionId,
      this.userId,
      this.id,
      this.userType,
      this.schoolUserType,
      this.schoolId,
      this.year,
      this.correlationId});

  String sessionId, userId, id, correlationId;
  int userType, schoolUserType, schoolId, year;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
      sessionId: '',
      userId: json['userId'],
      id: "${json['idNumber']}",
      userType: json['userType'],
      schoolUserType: json['schoolUserType'],
      schoolId: json['semel'],
      year: json['year'],
      correlationId: json['correlationId']);

  Map<String, dynamic> toJson() => {
        'sessionId': '',
        'userId': userId,
        'id': id,
        'userType': userType,
        'schoolUserType': schoolUserType,
        'schoolId': schoolId,
        'year': year,
        'correlationId': correlationId
      };

}
