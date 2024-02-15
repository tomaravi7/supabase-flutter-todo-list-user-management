import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './main.dart';
import './userinfo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  User? user = supabase.auth.currentUser;
  final List todoList = [];
  bool showDone = false;
  String newTitle = "";
  String newDesc = " ";
  DateTime dt = DateTime.now();

  Future<void> getTodoList() async {
    try {
      final data =
          await supabase.from('todos').select().eq('user_id', user!.id);
      todoList.clear();
      for (var i = 0; i < data.length; i++) {
        todoList.add(data[i]);
      }
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> updateTodo(int index, bool? value) async {
    try {
      await supabase
          .from('todos')
          .update({'is_complete': value}).eq('id', todoList[index]['id']);
      setState(() {
        todoList[index]['is_complete'] = value;
      });
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    }
  }

  Future<void> addList() async {
    setState(() {
      showAdaptiveDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              title: const Text('Add Task'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Task',
                      hintText: 'Enter Task',
                      border: OutlineInputBorder()),
                  onChanged: (value) {
                    setState(() {
                      newTitle = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter Description',
                      border: OutlineInputBorder()),
                  onChanged: (value) {
                    setState(() {
                      newDesc = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addTodo();
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ]),
            );
          });
    });
  }

  Future<void> addTodo() async {
    if (newTitle.isEmpty || newDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task and Description cannot be empty'),
        ),
      );
      return;
    }
    try {
      await supabase.from('todos').upsert([
        {
          'task': newTitle.toString(),
          'task_desc': newDesc.toString(),
          'user_id': user!.id,
          'is_complete': false,
          'inserted_at': DateTime.now().toIso8601String(),
        }
      ]);
      getTodoList();
    } on Exception catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    } finally {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task Added'),
          ),
        );
      }
    }
  }

  Future<void> deleteTodo(int index) async {
    try {
      await supabase.from('todos').delete().eq('id', todoList[index]['id']);
      setState(() {
        todoList.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task Deleted'),
          ),
        );
      });
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    }
  }

  Future<void> deleteAll() async {
    try {
      await supabase.from('todos').delete().eq('user_id', user!.id);
      setState(() {
        todoList.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All Tasks Deleted'),
          ),
        );
      });
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottomOpacity: 20,
        title: Center(child: Text('${user!.email} Todo List')),
        actions: [
          Tooltip(
              message:
                  showDone ? 'Hide Completed Tasks' : 'Show Completed Tasks',
              child: (todoList
                      .where((element) => element['is_complete'])
                      .isNotEmpty)
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          showDone = !showDone;
                        });
                      },
                      icon: showDone
                          ? const Icon(Icons.check_circle_outline)
                          : const Icon(Icons.circle_outlined))
                  : const SizedBox()),
          Tooltip(
              message: 'User Information',
              child: IconButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserPage())),
                  icon: const Icon(Icons.person))),
          Tooltip(
              message: 'Delete All Tasks',
              child: IconButton(
                  onPressed: () {
                    showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete All Tasks?'),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                      'Are you sure you want to delete all tasks?'),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          deleteAll();
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ]),
                          );
                        });
                  },
                  icon: const Icon(Icons.delete_forever_outlined))),
        ],
      ),
      body: Align(
          alignment: Alignment.topCenter,
          child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                DateTime dt = DateTime.parse(todoList[index]['inserted_at']);
                if (todoList[index]['is_complete'] && !showDone) {
                  return Container();
                }
                return ListTile(
                  title: Text(todoList[index]['task'],
                      style: TextStyle(
                          decoration: todoList[index]['is_complete']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationThickness: 5,
                          decorationStyle: TextDecorationStyle.wavy,
                          decorationColor: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  subtitle: todoList[index]['task_desc'] != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoList[index]['task_desc']!,
                              style: TextStyle(
                                  decoration: todoList[index]['is_complete']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: Colors.black,
                                  decorationThickness: 5,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Created: ${dt.hour}:${dt.minute} ${dt.day}/${dt.month}/${dt.year}',
                                style: TextStyle(
                                    decoration: todoList[index]['is_complete']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: Colors.black,
                                    decorationThickness: 5,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold))
                          ],
                        )
                      : null,
                  hoverColor: Colors.black38,
                  trailing: Checkbox(
                    value: todoList[index]['is_complete'],
                    onChanged: (bool? value) {
                      updateTodo(index, value);
                    },
                    activeColor: const Color(0xFF3ecfb2),
                  ),
                  onLongPress: () => deleteTodo(index),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: addList,
        child: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
  }
}
