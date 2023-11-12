import 'package:flutter/material.dart';
import 'package:healthy_cook/components/home_cards.dart';
import 'package:line_icons/line_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();
  DateTime? startDate;

  initializeDate() {
    startDate = DateTime(now.year, now.month, 1);
  }

  showDatePickerDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF2F2F2),
              onPrimary: Color(0xFF1D7332),
              onSurface: Color(0xFF1D7332),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1D7332)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9DF6B0),
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20, color: Color(0xFF1C4036)),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: showDatePickerDialog,
              icon: const LineIcon.calendar(),
              color: const Color(0xFF1C4036),
            )
          ],
        ),
        body: Column(
          children: [
            HomeFeed(
              date: startDate,
            ),
          ],
        ));
  }
}
