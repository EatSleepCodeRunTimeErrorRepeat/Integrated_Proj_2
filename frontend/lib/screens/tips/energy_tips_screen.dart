// lib/screens/tips/energy_tips_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/notes_provider.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';

// This provider tracks if a change was made on this screen.
final didChangeNotesProvider = StateProvider<bool>((ref) => false);

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
  void initState() {
    super.initState();
    // Reset the change tracker when the screen is first built.
    Future.microtask(
        () => ref.read(didChangeNotesProvider.notifier).state = false);
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider(widget.selectedDate));

    final onPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'ON_PEAK').toList();
    final offPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'OFF_PEAK').toList();
    final currentList = _selectedPeriod == 0 ? onPeakNotes : offPeakNotes;

    // Use PopScope to handle back navigation and pass a result.
    return PopScope(
      canPop: false, // Prevents automatic popping.
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // When a pop is attempted, manually pop with the result.
        Navigator.of(context).pop(ref.read(didChangeNotesProvider));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F2E5),
        appBar: AppBar(
          title: Text(
              'Tips for ${DateFormat.yMMMMd().format(widget.selectedDate)}',
              style: const TextStyle(fontSize: 18)),
          // Update the leading back button to use our manual pop logic.
          leading: BackButton(
            color: AppTheme.textBlack,
            onPressed: () {
              Navigator.of(context).pop(ref.read(didChangeNotesProvider));
            },
          ),
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
                child: notesState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNotesList(currentList),
              ),
              if (_isEditing) _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditNoteDialog({Note? note}) {
    final notesNotifier = ref.read(notesProvider(widget.selectedDate).notifier);
    final isEditingNote = note != null;
    final textController =
        TextEditingController(text: isEditingNote ? note.content : '');

    String dialogPeakPeriod = isEditingNote
        ? note.peakPeriod
        : (_selectedPeriod == 0 ? 'ON_PEAK' : 'OFF_PEAK');
    DateTime initialDateTime = isEditingNote ? note.date : DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initialDateTime);
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
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => dialogPeakPeriod = value);
                            }
                          },
                        ),
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
                    if (content.isEmpty) return;

                    final finalDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute);
                    final DateTime? reminderTime =
                        reminderEnabled ? finalDateTime : null;

                    bool success = false;
                    if (isEditingNote) {
                      success = await notesNotifier.updateNote(
                          note.id, content, dialogPeakPeriod, finalDateTime,
                          remindAt: reminderTime);
                    } else {
                      success = await notesNotifier.addNote(
                          content, dialogPeakPeriod, finalDateTime,
                          remindAt: reminderTime);
                    }

                    if (success) {
                      ref.read(didChangeNotesProvider.notifier).state = true;
                      await notesNotifier.refresh();
                      // Check if context is still valid before using it
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

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        if (_isEditing) {
          _showAddEditNoteDialog();
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

  Widget _buildNotesList(List<Note> notes) {
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
          onTap: _isEditing ? () => _showAddEditNoteDialog(note: note) : null,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFF545454).withAlpha(15),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text(
                  DateFormat('HH:mm').format(note.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF545454)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(note.content,
                      style: const TextStyle(
                          color: Color(0xFF545454), fontSize: 16)),
                ),
                if (_isEditing)
                  IconButton(
                    icon: Image.asset('assets/icons/cancel.png',
                        width: 18, height: 18),
                    onPressed: () async {
                      final notesNotifier =
                          ref.read(notesProvider(widget.selectedDate).notifier);
                      final success = await notesNotifier.deleteNote(note.id);
                      if (success) {
                        ref.read(didChangeNotesProvider.notifier).state = true;
                        await notesNotifier.refresh();
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
