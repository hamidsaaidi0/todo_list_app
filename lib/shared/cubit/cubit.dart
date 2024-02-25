import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived/archived.dart';
import 'package:todo_app/modules/tasks/tasks.dart';
import 'package:todo_app/modules/todolist/todolist.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    Tasks(),
    TodoList(),
    Archived(),
  ];
  List<String> appBarTitle = ['Tasks', 'Done', 'Archived'];
  Database? database;
  List<Map> newtasksList = [];
  List<Map> donetasksList = [];
  List<Map> archivedtasksList = [];
  bool bottomSheetShow = false;
  void ChangeCurentIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void changeBottomSheetState({required bool value}) {
    bottomSheetShow = value;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        print('database Created');
        db
            .execute(
                'Create Table Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT , time TEXT, status TEXT)')
            .then(
          (value) {
            print('table created');
          },
        ).catchError(
          (onError) {
            print('Erro When created Table : ${onError}');
          },
        );
      },
      onOpen: (db) {
        getFromDatabase(db);
        print('database opened');
      },
    ).then((value) {
      database = value;
    }).catchError((onError) => print('Create Database error $onError'));
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database?.transaction((txn) async {
      txn
          .rawInsert(
        'Insert INTO Tasks(title, date, time, status) Values ("$title","$date","$time","new")',
      )
          .then(
        (value) {
          print('insred ${value}');
          changeBottomSheetState(value: false);
          getFromDatabase(database);
          emit(AppInsertIntoDatabase());
          emit(AppShowButtomSheet());
        },
      ).catchError(
        (onError) {
          print(onError);
        },
      );
    });
  }

  void getFromDatabase(database) {
    newtasksList = [];
    donetasksList = [];
    archivedtasksList = [];
    database.rawQuery('SELECT * FROM Tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newtasksList.add(element);
        } else if (element['status'] == 'done') {
          donetasksList.add(element);
        } else
          archivedtasksList.add(element);
      });
      emit(AppGetFromDatabase());
    }).catchError(
      (onError) => print('Get data from database error : $onError'),
    );
  }

  void updateFromDatabase({required String status, required int id}) {
    database?.rawUpdate('UPDATE Tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getFromDatabase(database);
      emit(AppupdateFromDatabase());
    });
  }
  void deleteFromDatabase({required int id}) {
    database?.rawDelete('DELETE FROM Tasks WHERE id = ?',
        [ id]).then((value) {
      getFromDatabase(database);
      emit(AppDeleteFromDatabase());
    });
  }
}
