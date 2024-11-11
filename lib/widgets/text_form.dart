
import 'package:flutter/material.dart';

Widget MiuraTextFormField({required TextEditingController controller, required String hintText})   {
  return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black38)),
          hintText: hintText,
          labelText: hintText
        ),


  );

}