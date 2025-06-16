import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';
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
  final _searchController = TextEditingController();
  List<Note> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchLoading = false;
  final TextEditingController _newTipController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _newTipController.dispose();
    super.dispose();
  }

  // --- LOGIC ---
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
    });

    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.searchNotes(query);

    if (mounted) {
      if (response.statusCode == 200) {
        final notes = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        setState(() {
          _searchResults = notes;
          _isSearchLoading = false;
        });
      } else {
        setState(() {
          _isSearchLoading = false;
          _searchResults = [];
        });
      }
    }
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider(widget.selectedDate));
    final notesNotifier = ref.read(notesProvider(widget.selectedDate).notifier);

    final onPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'ON_PEAK').toList();
    final offPeakNotes =
        notesState.notes.where((n) => n.peakPeriod == 'OFF_PEAK').toList();
    final currentList = _selectedPeriod == 0 ? onPeakNotes : offPeakNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E5), // Background color
      appBar: AppBar(
        title: const Text('Energy Saving Tips'),
        leading: const BackButton(color: AppTheme.textBlack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search all your tips...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch(''); // Clear search results
                          FocusScope.of(context).unfocus(); // Dismiss keyboard
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF7F8F9), // Light gray background
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              onSubmitted:
                  _performSearch, // Search when user presses done/enter
            ),
            const SizedBox(height: 16),

            // Main Controls
            Row(
              children: [
                Expanded(child: _buildPeriodToggle()),
                const SizedBox(width: 16),
                _buildEditButton(notesNotifier),
              ],
            ),
            const SizedBox(height: 20),

            // The main list view
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _buildMainContent(notesState, currentList, notesNotifier),
              ),
            ),

            if (_isEditing) _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  /// Determines whether to show search results, the default list, or a loader.
  Widget _buildMainContent(NotesState notesState, List<Note> currentList,
      NotesNotifier notesNotifier) {
    if (_isSearching) {
      if (_isSearchLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildNotesList(_searchResults, notesNotifier,
          key: const ValueKey('search_results'));
    } else {
      if (notesState.isLoading && notesState.notes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildNotesList(currentList, notesNotifier,
          key: ValueKey(_selectedPeriod));
    }
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

  Widget _buildEditButton(NotesNotifier notifier) {
    return GestureDetector(
      onTap: () {
        if (_isEditing) {
          _showAddEditNoteDialog(notifier: notifier);
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

  Widget _buildPeriodToggle() {
    final isDisabled = _isSearching;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
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
            Expanded(
                child: _buildToggleButton(
                    0, 'On-Peak', AppTheme.peakRed, isDisabled)),
            Expanded(
                child: _buildToggleButton(
                    1, 'Off-Peak', AppTheme.offPeakGreen, isDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      int index, String text, Color activeColor, bool isDisabled) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedPeriod = index),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, NotesNotifier notifier,
      {required Key key}) {
    if (notes.isEmpty) {
      final message = _isSearching
          ? 'No results found.'
          : 'No tips for this period. ${_isEditing ? "Add one!" : ""}';
      return Center(key: key, child: Text(message));
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
                    onPressed: () => notifier
                        .deleteNote(note.id)
                        .then((_) => _performSearch(_searchController.text)),
                  ),
                Expanded(
                  child: Text(note.content,
                      style: const TextStyle(
                          color: Color(0xFF545454), fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditNoteDialog({required NotesNotifier notifier, Note? note}) {
    final isEditingNote = note != null;
    final textController =
        TextEditingController(text: isEditingNote ? note.content : '');
    String dialogPeakPeriod = isEditingNote
        ? note.peakPeriod
        : (_selectedPeriod == 0 ? 'ON_PEAK' : 'OFF_PEAK');
    TimeOfDay selectedTime =
        isEditingNote ? TimeOfDay.fromDateTime(note.date) : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
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
                        fillColor: Color.fromARGB(255, 245, 245, 244),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 2),
                        ),
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
                          child: Text(
                            selectedTime.format(context),
                            style: TextStyle(color: AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel',
                      style: TextStyle(color: AppTheme.primaryGreen)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final content = textController.text.trim();
                    if (content.isNotEmpty) {
                      final finalDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      Future<void> action;

                      // Add the new note if not editing, or update if editing
                      if (isEditingNote) {
                        action = notifier.updateNote(
                          note.id,
                          content,
                          dialogPeakPeriod,
                          finalDateTime,
                        );
                      } else {
                        action = notifier.addNote(
                          content,
                          dialogPeakPeriod,
                          finalDateTime,
                        );
                      }

                      // Wait for the action to complete
                      await action;

                      // Debugging: Ensure note is added
                      print('Note Added: $content');

                      // Refresh the UI after adding the note
                      if (_isSearching && mounted) {
                        _performSearch(_searchController.text);
                      }

                      // Dismiss the dialog after saving
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      // Update the state to refresh the UI
                      setState(() {});
                    } else {
                      print('Content is empty');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
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
