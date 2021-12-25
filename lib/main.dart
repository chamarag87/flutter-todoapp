
// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:todolatest/models/todo_info.dart';
import 'package:todolatest/todo_helper.dart';
import 'package:intl/intl.dart';

void main() => runApp( TodoApp());
const primaryColor = Colors.green;
class TodoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
        ),
        title: 'Todo List',
        home:  TodoList()
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() =>  TodoListState();
}

class TodoListState extends State<TodoList> {
  late Future<List<TodoInfo>> _todoItems;
  late Future<String> _todoItem;
  final TodoHelper _todoHelper = TodoHelper();





  @override
  void initState(){
    //initialize database connection
    _todoHelper.initializeDatabase().then((value){
      // print('---database initialize');
//get all the existing todos
      setState(() {
        _todoItems = _todoHelper.getTodos();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title:  Text('Todo List'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              alignment: Alignment.center,
              height: 50.0,
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.green,
              child: Row(children: [

                Expanded(

                  flex: 3,

                  child: TextField(
                    onChanged: (val) {
                      var newTodoInfo = TodoInfo(
                        id: 0,
                        title:  val,
                        dateTime: 'null'
                      );

                      setState(() {
                        if(val.isEmpty){
                          _todoItems =  _todoHelper.getTodos();
                        }else if(val.isNotEmpty){
                          _todoItems = _todoHelper.getTodo(val);
                        }

                      });

                    },
                    textAlign: TextAlign.center,

                    decoration:  InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'Search Todo',
                      contentPadding: const EdgeInsets.all(5.0),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),

                ),

              ],),
            ),
          ),
          Expanded(
            child: Container(
                alignment: Alignment.center,
                color: Colors.green,
                child: _buildTodoList()
            ),
          ),

        ],
      ),

      //add new task button
      floatingActionButton:  FloatingActionButton.extended(
          onPressed: _pushAddTodoScreen, // pressing this button now opens the  screen
          tooltip: 'Add task',
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepOrange,
          icon: Icon(
              Icons.add_task
          ),
          label:  Text('Add New Task')

      ),

    );
  }


// Build the whole list of todo items
  @override
  Widget _buildTodoList() {

    return FutureBuilder<List<TodoInfo>>(
      future: _todoItems, // function where you call your api
      builder: (context, snapshot) {  // AsyncSnapshot<Your object type>
        //waiting till data pass
        if( snapshot.connectionState == ConnectionState.waiting){
          return  Center(child: Text('Please wait its loading...'));
        }else{
          //if any errors
          if (snapshot.hasError) {

            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else {
            //  data found from the sqflit db
            if(snapshot.hasData && !snapshot.data!.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(8),
                children: snapshot.data!.map<Widget>((todo) {
                  return
                    Card(child:
                    ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.dateTime),
                        onTap: () =>
                            _promptRemoveTodoItem(todo.id, todo.title),
                        trailing: Icon(Icons.edit_rounded)
                    )
                    );
                }).toList(),

              );
            }else{
              //no data found
              return  Center(child: Text('No Todo List Found '));
            }
          }
        }
      },
    );

  }
  //modal popup design for
  void _promptRemoveTodoItem(index,title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return  AlertDialog(
            // title:  Text('Please select an option for "${_todoItems[index]}"'),
              title:  Text('Please select an option to go forward'),
              actions: <Widget>[
                TextButton(
                    child:  Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                TextButton(
                    child:  Text('DELETE'),
                    onPressed: () {
                      setState(() {
                        //call delete method to remove the item from database
                        _todoHelper.delete(index);
                        //get latest todo list after deleting the record
                        _todoItems = _todoHelper.getTodos();
                      });

                      //show success message and close the modal
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Removed Successfully')));
                      Navigator.of(context).pop();
                    }
                ),
                TextButton(
                    child:  Text('EDIT'),
                    onPressed: () {
                      //navigate to edit screen
                      _pushUpdateTodoScreen(index,title);
                    }
                )
              ]
          );
        }
    );
  }

  //adding new todo screen
  void _pushAddTodoScreen() {
    //generate current date and time
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well
      // as adding a back button to close it
        MaterialPageRoute(
            builder: (context) {
              return  Scaffold(
                  appBar:  AppBar(
                      backgroundColor: Colors.lightGreen,
                      title:  Text('Add a new todo item')
                  ),
                  body:  TextField(
                    autofocus: true,
                    onSubmitted: (val) {
                      //on submit prepare the todo object wih title and datetime
                      var newTodoInfo = TodoInfo(
                          title:  val,
                          dateTime:formattedDate
                      );

                      setState(() {
                        //pass form data to insert method
                        _todoHelper.insertTodo(newTodoInfo);
                        //get latest todo list after inserting the record
                        _todoItems =  _todoHelper.getTodos();
                      });
                      //show success message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Added Successfully')));
                      Navigator.pop(context); // Close the add todo screen
                    },
                    decoration:  InputDecoration(
                        hintText: 'Enter something to do...',
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );}

  //update selected todo item
  void _pushUpdateTodoScreen(index,title) {

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well
      // as adding a back button to close it
        MaterialPageRoute(

            builder: (context) {
              return  Scaffold(
                  appBar:  AppBar(
                      backgroundColor: Colors.lightGreen,
                      title:   Text('Update the Todo Item')

                  ),
                  body:  TextField(
                    autofocus: true,

                    controller: TextEditingController(text: title),
                    onSubmitted: (val) {
                      //on submit prepare the todo object wih id, title and datetime
                      var newTodoInfo = TodoInfo(
                          id: index,
                          title:  val,
                          dateTime: formattedDate

                      );
                      setState(() {
                        //call update method
                        _todoHelper.update(newTodoInfo);
                        //get latest todo list after updating the record
                        _todoItems =  _todoHelper.getTodos();
                      });
                      //show success message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Updated Successfully')));
                      Navigator.pop(context); // Close the update todo screen
                      Navigator.of(context).pop();
                    },
                    decoration:  InputDecoration(
                        hintText: 'Enter something to do...',
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );}



}