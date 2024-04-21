
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'dart:io';

class first_ extends StatefulWidget {
  const first_({super.key});

  @override
  State<first_> createState() => _first_State();
}

class _first_State extends State<first_> {
  TextEditingController _rollNumberController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  List<String> students = [];
  List<String> randomizedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  _loadStudents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    students = prefs.getStringList('students') ?? [];
    setState(() {});
  }

  _saveStudent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentInfo = '${_rollNumberController.text}: ${_nameController.text}';
    students.add(studentInfo);
    prefs.setStringList('students', students);
    _rollNumberController.clear();
    _nameController.clear();
    setState(() {});
  }

  _randomizeStudents() {
    setState(() {
      randomizedStudents = List.from(students)..shuffle();
    });
  }
  _generatePDF() async {
    final pdf = pdfLib.Document();

    // Function to format student info with seat number
    String formatStudent(int index, String student) {
      return 'Seat ${index + 1}: $student';
    }

    pdf.addPage(pdfLib.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => <pdfLib.Widget>[
          pdfLib.Header(level: 0, child: pdfLib.Text('Randomized Student List')),
          for (var i = 0; i < randomizedStudents.length; i++)
            pdfLib.Text(formatStudent(i, randomizedStudents[i])),
        ]));

    // Save the PDF file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/randomized_student_list.pdf';
    final File file = File(path);
    final Uint8List pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);

    print('PDF generated successfully at: $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _rollNumberController,
              decoration: InputDecoration(labelText: 'Roll Number'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
          ),
          ElevatedButton(
            onPressed: _saveStudent,
            child: Text("Register"),
          ),
          ElevatedButton(
            onPressed: () {
              _randomizeStudents();
              _generatePDF();
            },
            child: Text("Randomize and Generate PDF"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: randomizedStudents.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(randomizedStudents[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
