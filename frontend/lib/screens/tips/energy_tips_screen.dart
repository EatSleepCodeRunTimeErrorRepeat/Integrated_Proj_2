// lib/screens/tips/energy_tips_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/notes_provider.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';

class EnergyTipsScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const EnergyTipsScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<EnergyTipsScreen> createState() => _EnergyTipsScreenState();
}

class _EnergyTipsScreenState extends ConsumerState<EnergyTipsScreen> {
  int _selectedPeriod = 0; // 0 for On-Peak, 1 for Off-Peak
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    // Watch the provider for the selected date. The UI will rebuild when notes change.
    final notesState = ref.watch(notesProvider(widget.selectedDate));
    // Get the provider's notifier to call methods like addNote, deleteNote, etc.
    final notesNotifier = ref.read(notesProvider(widget.selectedDate).notifier);

    // Filter notes based on the selected toggle (On-Peak/Off-Peak)
    final onPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'ON_PEAK').toList();
    final offPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'OFF_PEAK').toList();
    final currentList = _selectedPeriod == 0 ? onPeakNotes : offPeakNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5),
      appBar: AppBar(
        title: Text(
            'Tips for ${DateFormat.yMMMMd().format(widget.selectedDate)}',
            style: const TextStyle(fontSize: 18)),
        leading: const BackButton(color: AppTheme.textBlack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main Controls: Toggle and Edit/Add Button
            Row(
              children: [
                Expanded(child: _buildPeriodToggle()),
                const SizedBox(width: 16),
                _buildEditButton(notesNotifier),
              ],
            ),
            const SizedBox(height: 20),
            // The main list of notes
            Expanded(
              child: notesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildNotesList(currentList, notesNotifier),
            ),
            // The "Done" button that appears in edit mode
            if (_isEditing) _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildPeriodToggle() {
    return Container(
      height: 59,
      decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 6)
          ]),
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
            borderRadius: BorderRadius.circular(10)),
        child: Center(
            child: Text(text,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textGrey,
                    fontWeight: FontWeight.w500))),
      ),
    );
  }

  Widget _buildEditButton(NotesNotifier notifier) {
    return GestureDetector(
      onTap: () {
        if (_isEditing) {
          // In edit mode, this button opens the "Add New Tip" dialog
          _showAddEditNoteDialog(notifier: notifier);
        } else {
          // Not in edit mode, so this button enables it
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
            _isEditing ? 'assets/icons/add.png' : 'assets/icons/editpencil.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
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

  Widget _buildNotesList(List<Note> notes, NotesNotifier notifier) {
    if (notes.isEmpty) {
      return Center(
          child:
              Text('No tips for this period. ${_isEditing ? "Add one!" : ""}'));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return InkWell(
          // Allow tapping a note to edit it, but only in edit mode
          onTap: _isEditing
              ? () => _showAddEditNoteDialog(notifier: notifier, note: note)
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFF545454).withAlpha(15),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Text(note.content,
                      style: const TextStyle(
                          color: Color(0xFF545454), fontSize: 16)),
                ),
                // Show the delete button only in edit mode
                if (_isEditing)
                  IconButton(
                    icon: Image.asset('assets/icons/cancel.png',
                        width: 18, height: 18),
                    onPressed: () => notifier.deleteNote(note.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- THE RESTORED AND STYLED DIALOG ---
  void _showAddEditNoteDialog({required NotesNotifier notifier, Note? note}) {
    final isEditingNote = note != null;
    final textController =
        TextEditingController(text: isEditingNote ? note.content : '');

    // State for the dialog's controls
    String dialogPeakPeriod = isEditingNote
        ? note.peakPeriod
        : (_selectedPeriod == 0 ? 'ON_PEAK' : 'OFF_PEAK');
    DateTime initialDateTime = note?.remindAt ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialDateTime);
    // NEW: state for the reminder toggle
    bool reminderEnabled = isEditingNote && note.remindAt != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(isEditingNote ? 'Edit Tip' : 'Add New Tip'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Enter your savings tip...',
                        filled: true,
                        fillColor: AppTheme.lightGrey,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Controls for Peak Period and Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dropdown for On-Peak/Off-Peak
                        DropdownButton<String>(
                          value: dialogPeakPeriod,
                          items: const [
                            DropdownMenuItem(
                                value: 'ON_PEAK', child: Text('On-Peak')),
                            DropdownMenuItem(
                                value: 'OFF_PEAK', child: Text('Off-Peak')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => dialogPeakPeriod = value);
                            }
                          },
                        ),
                        // --- NEW: ROW FOR REMINDER TOGGLE AND TIME ---
                        Row(
                          children: [
                            Switch(
                              value: reminderEnabled,
                              onChanged: (value) =>
                                  setDialogState(() => reminderEnabled = value),
                              activeColor: AppTheme.primaryGreen,
                            ),
                            TextButton(
                              onPressed: !reminderEnabled
                                  ? null
                                  : () async {
                                      final TimeOfDay? picked =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: selectedTime);
                                      if (picked != null) {
                                        setDialogState(
                                            () => selectedTime = picked);
                                      }
                                    },
                              child: Text(
                                selectedTime.format(context),
                                style: TextStyle(
                                    color: reminderEnabled
                                        ? AppTheme.primaryGreen
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.primaryGreen)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final content = textController.text.trim();
                    if (content.isNotEmpty) {
                      // Combine the selected date with the new time for the final DateTime object.
                      final finalDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      // Determine the reminder time. It's the finalDateTime if enabled, otherwise null.
                      final DateTime? reminderTime =
                          reminderEnabled ? finalDateTime : null;

                      if (isEditingNote) {
                        await notifier.updateNote(
                            note.id, content, dialogPeakPeriod, finalDateTime,
                            remindAt: reminderTime);
                      } else {
                        await notifier.addNote(
                            content, dialogPeakPeriod, finalDateTime,
                            remindAt: reminderTime);
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      // If reminder is enabled, we will use the finalDateTime as the remindAt time.
                      // The 'remindAt' field will be set on the Note object before sending to the backend
                      // This requires a modification in the updateNote/addNote API call
                      // For now, we will handle this locally by passing the reminder time to the provider.
                      // NOTE: We need to adapt the Note model and API calls to include 'remindAt'

                      // For simplicity in this step, let's assume we pass a new note object
                      // This part requires updating the Note model and the API service to handle 'remindAt'

                      // Let's create a temporary note object to pass to the provider
                      Note noteToSave = Note(
                        id: note?.id ?? '',
                        content: content,
                        peakPeriod: dialogPeakPeriod,
                        date: finalDateTime,
                        remindAt: reminderEnabled ? finalDateTime : null,
                      );

                      if (isEditingNote) {
                        // This assumes updateNote can handle the new Note object structure
                        await notifier.updateNote(
                            noteToSave.id,
                            noteToSave.content,
                            noteToSave.peakPeriod,
                            noteToSave.date);
                      } else {
                        // This assumes addNote can handle the new Note object structure
                        await notifier.addNote(noteToSave.content,
                            noteToSave.peakPeriod, noteToSave.date);
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen),
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
