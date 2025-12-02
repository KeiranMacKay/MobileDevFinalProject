import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../database/db_helper.dart';

class AddBill extends StatefulWidget {
  const AddBill({super.key});

  @override
  State<AddBill> createState() => _BillEntryFormState();
}

class _BillEntryFormState extends State<AddBill> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedName;
  bool _isReoccurring = false;

  // dynamic dropdown list names from DB
  List<String> _names = [];

  // for camera / photo capture
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingReceipt = false;
  String? _receiptImagePath; // path to the captured photo

  @override
  void initState() {
    super.initState();
    _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    final db = await WalletFlowDB.instance.database;
    if (db == null) return;

    final result = await db.query('members', columns: ['nickname']);
    setState(() {
      _names = result.map((row) => row['nickname'] as String).toList();
    });
  }

  @override
  void dispose() {
    _placeController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final place = _placeController.text.trim();
    final date = _dateController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    final name = _selectedName ?? 'Unknown';

    final expense = Expense(
      name: name,
      place: place,
      date: date,
      price: price,
      isRecurring: _isReoccurring,
      notes: notes,
      receiptUri: _receiptImagePath, // save image path in DB
    );

    try {
      final id = await WalletFlowDB.instance.insertExpense(expense);

      debugPrint(
        'AddBill: inserted expense id=$id '
            'Name: $name, Place: $place, Date: $date, Price: $price, '
            'Reoccurring: $_isReoccurring, Notes: $notes, '
            'ReceiptUri: $_receiptImagePath',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            id == null
                ? 'Bill added (local only, DB not available on this platform).'
                : 'Bill added successfully!',
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // clear fields
      _placeController.clear();
      _dateController.clear();
      _priceController.clear();
      _notesController.clear();
      setState(() {
        _selectedName = null;
        _isReoccurring = false;
        _receiptImagePath = null;
      });
    } catch (e) {
      debugPrint('AddBill: error inserting bill: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving bill to database'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _onPhotoAddPressed() async {
    try {
      setState(() => _isProcessingReceipt = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _receiptImagePath = pickedFile.path;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo has been captured'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error with photo capture $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error with photo capture $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingReceipt = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Bill Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // dropdown row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Name',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedName,
                        items: _names
                            .map(
                              (name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedName = value;
                          });
                        },
                        validator: (value) =>
                        value == null ? 'Select a name' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _isReoccurring,
                          onChanged: (value) {
                            setState(() {
                              _isReoccurring = value ?? false;
                            });
                          },
                        ),
                        const Text('Reoccurring?'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // place
                TextFormField(
                  controller: _placeController,
                  decoration: const InputDecoration(
                    labelText: 'Place',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a place' : null,
                ),
                const SizedBox(height: 12),

                // date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a date';
                    }
                    final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!reg.hasMatch(value)) {
                      return 'Enter date in format YYYY-MM-DD';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 8),

                // Image Preview
                if (_receiptImagePath != null) ...[
                  Text(
                    'Receipt photo preview:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_receiptImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 20),

                // buttons row
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isProcessingReceipt
                              ? null
                              : _onPhotoAddPressed,
                          child: _isProcessingReceipt
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Photo add'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text(
                            'Submit Bill',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
