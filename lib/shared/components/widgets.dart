import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget CostumTextFormField({
  required TextEditingController controller,
  String? labelText,
  Widget? suffixIcon,
  Widget? prefixIcon,
  String? Function(String?)? validator,
  void Function()? onTap,
  bool readOnly = false,
}) =>
    TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
      validator: validator,
      onTap: onTap,
    );

Widget buildTaskItem({required Map model, context}) => Dismissible(
      key: ValueKey<int>(model['id']),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.blue,
              child: Text(
                '${model["time"]}',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateFromDatabase(status: 'done', id: model['id']);
              },
              icon: Icon(
                Icons.check_box,
                color: Colors.green,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateFromDatabase(status: 'archived', id: model['id']);
              },
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      background: Container(
        color: Colors.red,
        child: Icon(Icons.delete),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteFromDatabase(id: model['id']);
      },
    );

Widget tasksBuilder({required List<Map> item}) => ConditionalBuilder(
      condition: item.length > 0,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) =>
            buildTaskItem(model: item[index], context: context),
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(
            start: 30.0,
          ),
          child: Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[400],
          ),
        ),
        itemCount: item.length,
      ),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              color: Colors.grey,
              size: 50,
            ),
            Text(
              "No Task yet, Please Add Some Tasks",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
