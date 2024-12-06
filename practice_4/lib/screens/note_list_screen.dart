import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:practice_4/providers/note_provider.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки SuperEasyNoteProvider')),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.notes;
          return notes.isEmpty
              ? const Center(child: Text('Нет заметок.'))
              : ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditScreen(note: note),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
