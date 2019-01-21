class Student {
  Student(
      {this.id,
      this.familyName,
      this.privateName,
      this.classCode,
      this.classNum});

  String id, familyName, privateName, classCode;
  int classNum;

  factory Student.fromJson(Map<String, dynamic> json) => Student(
      id: json['childGuid'],
      familyName: json['familyName'],
      privateName: json['privateName'],
      classCode: json['classCode'],
      classNum: json['classNum']);

  Map<String, dynamic> toJson() => {
        'childGuid': id,
        'familyName': familyName,
        'privateName': privateName,
        'classCode': classCode,
        'classNum': classNum
      };
}
