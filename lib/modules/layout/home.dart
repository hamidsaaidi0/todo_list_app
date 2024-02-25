import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/widgets.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class Home extends StatelessWidget {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void initState() {
    // createDatabase();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertIntoDatabase) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.appBarTitle[cubit.currentIndex],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.blue,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (value) {
                // setState(() {
                //   currentIndex = value;
                // });
                cubit.ChangeCurentIndex(value);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
              ],
            ),
            body: ConditionalBuilder(
              condition: true,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              )),
            ),
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0),
              ),
              backgroundColor: Colors.blue,
              child: Icon(
                cubit.bottomSheetShow ? Icons.add : Icons.edit,
                color: Colors.white,
              ),
              elevation: 5.0,
              onPressed: () {
                if (cubit.bottomSheetShow) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        elevation: 30.0,
                        (context) => Container(
                          padding: EdgeInsets.all(20.0),
                          color: Colors.white,
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CostumTextFormField(
                                    controller: titleController,
                                    prefixIcon: Icon(Icons.title),
                                    labelText: 'Task Title',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Task Title Must not be empty';
                                      }
                                    }),
                                SizedBox(
                                  height: 15.0,
                                ),
                                CostumTextFormField(
                                  controller: timeController,
                                  prefixIcon: Icon(Icons.watch_later_outlined),
                                  labelText: 'Task Time',
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Task Time Must not be empty';
                                    }
                                  },
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text = value != null
                                          ? value.format(context).toString()
                                          : timeController.text;
                                    }).catchError((onError) {
                                      print(
                                          'ShowTimePicker Error : ${onError}');
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                CostumTextFormField(
                                  controller: dateController,
                                  prefixIcon:
                                      Icon(Icons.calendar_month_outlined),
                                  labelText: 'Task Date',
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Task Date Must not be empty';
                                    }
                                  },
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2024-04-03'),
                                    ).then(
                                      (value) {
                                        dateController.text = value != null
                                            ? DateFormat.yMMMd().format(value)
                                            : dateController.text;
                                      },
                                    ).catchError(
                                      (onError) {
                                        print(
                                            'ShowTimePicker Error : ${onError}');
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(value: false);
                    // setState(() {
                    //   bottomSheetShow = false;
                    // });
                  });
                  cubit.changeBottomSheetState(value: true);
                  // setState(() {
                  //   bottomSheetShow = true;
                  // });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
