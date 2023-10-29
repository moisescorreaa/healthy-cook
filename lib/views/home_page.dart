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
          data: ThemeData.light(),
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
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: showDatePickerDialog,
                icon: const LineIcon.calendar())
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
