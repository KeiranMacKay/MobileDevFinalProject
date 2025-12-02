import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Fixed list of people for the dropdown
  final List<String> _names = [
    'Cheapy',
    'Spendy',
    'Wastey',
    'Hoardy',
    'Greedy',
    'John',
  ];

  // for camera / photo capture
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingReceipt = false;
  String? _receiptImagePath; // path to the captured photo

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

    if (_selectedName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String place = _placeController.text.trim();
    final String date = _dateController.text.trim();
    final double price = double.parse(_priceController.text.trim());
    final String? notes =
    _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final expense = Expense(
      name: _selectedName!,
      place: place,
      date: date,
      price: price,
      isRecurring: _isReoccurring,
      notes: notes,
      // store photo path directly in DB
      receiptUri: _receiptImagePath,
    );

    try {
      final id = await WalletFlowDB.instance.insertExpense(expense);
      debugPrint(
        'AddBill: inserted expense id=$id '
            'Name: ${expense.name}, Place: ${expense.place}, Date: ${expense.date}, '
            'Price: ${expense.price}, Reoccurring: ${expense.isRecurring}, '
            'Notes: ${expense.notes}, ReceiptUri: ${expense.receiptUri}',
      );

      // Reset form
      _placeController.clear();
      _dateController.clear();
      _priceController.clear();
      _notesController.clear();
      setState(() {
        _selectedName = null;
        _isReoccurring = false;
        _receiptImagePath = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill added successfully!'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
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

      // Opening the camera for use
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      // Dealing with user not taking the photo and cancelling
      if (pickedFile == null) {
        return;
      }

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
                // name + recurring row
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

                // Place
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

                // Date
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
                    final RegExp dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!dateRegExp.hasMatch(value)) {
                      return 'Enter date in format YYYY-MM-DD';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Price
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

                // Notes
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

                if (_receiptImagePath != null)
                  Text(
                    'Receipt photo attached.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.green),
                  ),
                const SizedBox(height: 20),

                // Buttons
                Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

