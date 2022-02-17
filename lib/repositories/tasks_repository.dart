import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lista_de_tarefas/models/todo.dart';

const todoListKey = 'todo_list';

class TasksRepository {
  late SharedPreferences sharedPreferences; // sharedPreferences armazena dados simples

  Future<List<Todo>> getTaskList() async {
    sharedPreferences = await SharedPreferences.getInstance(); // getInstance -> Obtem a instancia do objeto
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  void saveTaskList(List<Todo> todos) {
    final String jsonString = json.encode(todos);
    sharedPreferences.setString(todoListKey, jsonString);
  }
}