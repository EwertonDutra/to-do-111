import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lista_de_tarefas/models/todo.dart';
import 'package:lista_de_tarefas/widgets/tasks_list.dart';
import 'package:lista_de_tarefas/repositories/tasks_repository.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController todoController = TextEditingController();
  final TasksRepository tasksRepository = TasksRepository();

  List<Todo> tasks = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  @override
  void initState() {
    super.initState();

    tasksRepository.getTaskList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        // Mantem os widgets dentro da área segura do dispositivo
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo vazio';
                              }
                              return null;
                            },
                            maxLength: 40,
                            controller: todoController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Adicione uma Tarefa',
                                labelStyle: TextStyle(color: Color(0xff00d7f3)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xff00d7f3), width: 2))),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              todoController.text = todoController.text.trim();

                              if (_formKey.currentState!.validate()) {
                                String text = todoController.text;
                                setState(() {
                                  Todo newTodo = Todo(
                                    title: text,
                                    dateTime: DateTime.now(),
                                  );
                                  tasks.add(newTodo);
                                });
                                todoController.clear();
                                tasksRepository.saveTaskList(tasks);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff00d7f3),
                              padding: const EdgeInsets.all(14),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 30,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      //width: 50, -> Ao criar uma listView os componentes são esticados o maximo possivel na horizontal automaticamente
                      //shrinkWrap -> Deixa a lista mais enxuta
                      shrinkWrap: true,
                      children: [
                        for (Todo todo in tasks)
                          TasksListItem(
                            todo: todo,
                            onDelete: onDelete,
                          ),
                        /*ListTile(
                        title: Text(tasks),
                        onTap: () {
                          print('Tarefa: $tasks');
                        },
                      )*/
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                              'Você possui ${tasks.length} tarefas pendentes')),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          showDeleteDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: const EdgeInsets.all(14),
                        ),
                        child: Text('Limpar tudo'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    // CallBack de um Widget pai para um Widget Filho
    deletedTodo = todo;
    deletedTodoPos = tasks.indexOf(todo);

    setState(() {
      tasks.remove(todo);
    });
    tasksRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa ${todo.title} foi removida com sucesso!'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              tasks.insert(deletedTodoPos!, deletedTodo!);
            });
            tasksRepository.saveTaskList(tasks);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpart Tudo?'),
        content: Text('Você tem certeza que deseja deletar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Color(0xff00d7f3)),
            child: Text('Cancelar'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAll();
              },
              style: TextButton.styleFrom(primary: Colors.red),
              child: Text('Limpar Tudo'))
        ],
      ),
    );
  }

  void deleteAll() {
    setState(() {
      tasks.clear();
    });
    tasksRepository.saveTaskList(tasks);
  }
}
