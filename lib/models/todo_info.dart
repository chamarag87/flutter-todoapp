class TodoInfo {
  TodoInfo({
     this.id,
     required this.title,
     required this.dateTime,
  });

  int? id;
  String title;
  String dateTime;

  factory TodoInfo.fromMap(Map<String, dynamic> json) => TodoInfo(
    id: json["id"],
    title: json["title"],
    dateTime: json["dateTime"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "dateTime": dateTime,
  };
}