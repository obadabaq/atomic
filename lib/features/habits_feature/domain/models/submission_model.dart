class SubmissionModel {
  bool value;
  final String date;
  int count;

  SubmissionModel({
    required this.value,
    required this.date,
    this.count = 0,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      value: json['value'] ?? false,
      date: json['date'],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'date': date,
      'count': count,
    };
  }
}
