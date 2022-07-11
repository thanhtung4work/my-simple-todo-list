class Task {
  late String task;
  late DateTime dateTime;

  Task(this.task, this.dateTime);
  Map<String, dynamic> toMap(){
    return {"task": task, "createDate": dateTime.toString()};
  }
}