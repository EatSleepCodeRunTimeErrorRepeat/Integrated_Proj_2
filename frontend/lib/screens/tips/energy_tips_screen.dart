// lib/screens/tips/energy_tips_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/notes_provider.dart';
import 'package:frontend/utils/app_theme.dart';

class EnergyTipsScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const EnergyTipsScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends ConsumerState<EnergyTipsScreen> {
  int _selectedPeriod = 0;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider(widget.selectedDate));
    final notesNotifier = ref.read(notesProvider(widget.selectedDate).notifier);

    ref.listen<NotesState>(notesProvider(widget.selectedDate), (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppTheme.peakRed,
            ),
          );
      }
    });

    final onPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'ON_PEAK').toList();
    final offPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'OFF_PEAK').toList();
    final currentList = _selectedPeriod == 0 ? onPeakNotes : offPeakNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Saving Tips'),
        leading: const BackButton(color: AppTheme.textBlack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildPeriodToggle()),
                const SizedBox(width: 16),
                _buildEditButton(),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: notesState.isLoading && notesState.notes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNotesList(currentList, notesNotifier,
                        key: ValueKey(_selectedPeriod)),
              ),
            ),
            if (_isEditing) _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: GestureDetector(
        onTap: () => setState(() => _isEditing = false),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
              color: AppTheme.primaryGreen, shape: BoxShape.circle),
          child: Center(
              child: Image.asset('assets/icons/donedit.png',
                  width: 32, height: 32)),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        if (_isEditing) {
          _showAddEditNoteDialog(
              notifier: ref.read(notesProvider(widget.selectedDate).notifier));
        } else {
          setState(() => _isEditing = true);
        }
      },
      child: Container(
        width: 59,
        height: 59,
        decoration: const BoxDecoration(
            color: AppTheme.primaryGreen, shape: BoxShape.circle),
        child: Center(
            child: Image.asset(
                _isEditing
                    ? 'assets/icons/add.png'
                    : 'assets/icons/editpencil.png',
                width: 24,
                height: 24,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton(0, 'On-Peak', AppTheme.peakRed)),
          Expanded(
              child: _buildToggleButton(1, 'Off-Peak', AppTheme.offPeakGreen)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(int index, String text, Color activeColor) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Text(text,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textGrey,
                    fontWeight: FontWeight.w500))),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, NotesNotifier notifier,
      {required Key key}) {
    if (notes.isEmpty) {
      return Center(
          key: key,
          child:
              Text('No tips for this period. ${_isEditing ? "Add one!" : ""}'));
    }
    return ListView.builder(
      key: key,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return InkWell(
          onTap: _isEditing
              ? () => _showAddEditNoteDialog(notifier: notifier, note: note)
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF545454).withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (_isEditing)
                  IconButton(
                    icon: Image.asset('assets/icons/cancel.png',
                        width: 18, height: 18),
                    onPressed: () => notifier.deleteNote(note.id),
                  ),
                Expanded(
                    child: Text(note.content,
                        style: const TextStyle(
                            color: Color(0xFF545454), fontSize: 16))),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditNoteDialog({required NotesNotifier notifier, Note? note}) {
    final isEditing = note != null;
    final textController =
        TextEditingController(text: isEditing ? note.content : '');
    String dialogPeakPeriod = isEditing
        ? note.peakPeriod
        : (_selectedPeriod == 0 ? 'ON_PEAK' : 'OFF_PEAK');
    TimeOfDay selectedTime =
        isEditing ? TimeOfDay.fromDateTime(note.date) : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tip' : 'Add New Tip'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                          hintText: 'Enter your savings tip...'),
                      maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: dialogPeakPeriod,
                        items: const [
                          DropdownMenuItem(
                              value: 'ON_PEAK', child: Text('On-Peak')),
                          DropdownMenuItem(
                              value: 'OFF_PEAK', child: Text('Off-Peak')),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => dialogPeakPeriod = value!),
                      ),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                              context: context, initialTime: selectedTime);
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: Text(selectedTime.format(context)),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final content = textController.text.trim();
                    if (content.isNotEmpty) {
                      final finalDateTime = DateTime(
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          widget.selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute);
                      if (isEditing) {
                        await notifier.updateNote(
                            note.id, content, dialogPeakPeriod, finalDateTime);
                      } else {
                        await notifier.addNote(
                            content, dialogPeakPeriod, finalDateTime);
                      }
                      if (!dialogContext.mounted) return;
                      if (mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
