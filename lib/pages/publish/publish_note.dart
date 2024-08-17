import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/publish_notes_controller.dart';


class PublishNotes extends StatefulWidget {
  const PublishNotes({super.key});

  @override
  State<PublishNotes> createState() => _PublishNotesState();
}

class _PublishNotesState extends State<PublishNotes> {
  PublishNotesController publishNotesController=Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publish Notes'),
      ),
      body: Container(
        child: Center(
          child: Text('Publish Notes'),
        ),
      ),
    );
  }
}
