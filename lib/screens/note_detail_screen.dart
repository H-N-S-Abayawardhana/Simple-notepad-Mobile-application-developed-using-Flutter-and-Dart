import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final int? noteId;

  const NoteDetailScreen({Key? key, this.noteId}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    if (widget.noteId != null) {
      loadNote();
    }
  }

  Future loadNote() async {
    setState(() => isLoading = true);
    final note = await DatabaseHelper.instance.getNoteById(widget.noteId!);
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
    setState(() => isLoading = false);
  }

  Future saveNote() async {
    final note = Note(
      id: widget.noteId,
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    if (widget.noteId != null) {
      await DatabaseHelper.instance.update(note);
    } else {
      await DatabaseHelper.instance.create(note);
    }

    Navigator.pop(context);
  }

  Future deleteNote() async {
    if (widget.noteId != null) {
      await DatabaseHelper.instance.delete(widget.noteId!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.noteId == null ? 'New Note' : 'Edit Note',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[400],
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          if (widget.noteId != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteNote,
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveNote,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Content',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}