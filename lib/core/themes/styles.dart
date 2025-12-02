import 'package:flutter/material.dart';

class RideMetrxTheme {
  ThemeData themedata = ThemeData(
    useMaterial3: false,
    primaryColor: Color.fromARGB(255, 2, 107, 165), // 026ba5
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.black12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(fontSize: 16)
      ),
    ),
  );
}
