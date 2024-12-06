import 'package:flutter/material.dart';
import 'package:practice_4/models/note.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final SharedPreferences _prefs;

  NoteProvider(this._prefs) {
    _loadNotes();
  }

  List<Note> get notes => List.unmodifiable(_notes);

  void _loadNotes() {
    final String? savedNotes = _prefs.getString('notes');
    if (savedNotes != null) {
      final List<dynamic> decodedNotes = json.decode(savedNotes);
      _notes.addAll(
        decodedNotes.map((note) => Note(
          id: note['id'],
          title: note['title'],
          content: note['content'],
        )),
      );
    }
    notifyListeners();
  }

  void _saveNotes() {
    final String encodedNotes = json.encode(
      _notes.map((note) => {'id': note.id, 'title': note.title, 'content': note.content}).toList(),
    );
    _prefs.setString('notes', encodedNotes);
  }

  void addNote(String title, String content) {
    if (title.isEmpty) {
      throw ArgumentError("Название не может быть пустым.");
    }
    final newNote = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
    );
    _notes.add(newNote);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) {
      _notes[index] = Note(
        id: id,
        title: title,
        content: content,
      );
      _saveNotes();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
  }
}
