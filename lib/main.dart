import 'package:flutter/material.dart';
import 'package:my_todo_app/db/db_provider.dart';
import 'package:my_todo_app/model/task_model.dart';
void main() {
  runApp(
      const MaterialApp(
        home: MyToDoApp(),
        debugShowCheckedModeBanner: false,
      )
  );
}

class MyToDoApp extends StatefulWidget {
  const MyToDoApp({Key? key}) : super(key: key);

  @override
  State<MyToDoApp> createState() => _MyToDoAppState();
}

class _MyToDoAppState extends State<MyToDoApp> {
  Color mainColor = const Color(0xff76BA99);
  Color secondaryColor = const Color(0xffADCF9F);
  Color btnColor = const Color(0xffCED89E);
  Color editorColor = const Color(0xffFFDCAE);

  static TextEditingController editingController = TextEditingController();
  String newTaskInput = "";

  // get task from db
  getTasks() async {
    final tasks = await DBProvider.dataBase.getTasks();
    return tasks;
  }

  removeTasks(String task, String createDate) async {
    await DBProvider.dataBase.deleteTask(task, createDate);
  }

  String getWeekdayString(int weekday){
    if(weekday >= 1 && weekday <= 6){
      weekday++;
      return "Thu $weekday";
    }
    return "Chu nhat";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Todo List"),
        backgroundColor: mainColor,
        elevation: 0,
      ),
      backgroundColor: mainColor,
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                  future: getTasks(),
                  builder: (context, AsyncSnapshot taskData) {
                    switch (taskData.connectionState){
                      case ConnectionState.waiting:
                        {
                          return Center(child: CircularProgressIndicator());
                        }
                      case ConnectionState.done:
                        {
                          if (taskData.data != Null)
                          {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                                  child: ListView.builder(
                                      itemCount: taskData.data.length,
                                      itemBuilder: (context, index) {
                                        String task = taskData.data?[index]['task'];
                                        int weekday = DateTime.parse(taskData.data?[index]['createDate']).weekday;
                                        return Card(
                                          child: InkWell(child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                margin: EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                                  color: secondaryColor,
                                                ),
                                                child: Text(
                                                  getWeekdayString(weekday),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                                ),
                                              ),
                                              Expanded(
                                                  child: Text(task, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                                              ),
                                              IconButton(
                                                  onPressed: (){
                                                    setState((){
                                                      removeTasks(taskData.data[index]['task'], taskData.data[index]['createDate']);
                                                    });
                                                  },
                                                  icon: const Icon(Icons.check)),
                                            ],
                                          ),),
                                        );
                                  }),
                            );
                          } else {
                            return const Center(
                              child: Text("You don't have any task"),
                            );
                          }
                        }
                      default:
                        {
                          return Center(child: CircularProgressIndicator());
                        }
                    }
                  }
              )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
            decoration: BoxDecoration(
                color: editorColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4.0,),
                    Expanded(
                        child: TextField(
                          controller: editingController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "What is your task?",
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(width: 1, color: mainColor),
                            )
                          ),
                        )
                    ),
                    const SizedBox(width: 4.0,),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: (){
                          setState((){
                            newTaskInput = editingController.text.toString();
                            editingController.text = "";
                            Task newTask = Task(newTaskInput, DateTime.now());
                            DBProvider.dataBase.addNewTask(newTask);
                          });
                        },
                        icon: Icon(Icons.add),
                        label: Text("Thêm"),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: (){
                          setState((){
                            DBProvider.dataBase.removeAllTask();
                          });
                        },
                        icon: Icon(Icons.delete),
                        label: Text("Xóa tất cả"),
                      ),
                    ),
                  ],
                )

              ],
            )
          )
        ],
      ),
    );
  }
}
