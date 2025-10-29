import 'package:flutter/material.dart';

class AddBill extends StatefulWidget {
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

  //dropdown list names
  final List<String> _names = ['Cheapy', 'Spendy'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String place = _placeController.text;
      String date = _dateController.text;
      double price = double.parse(_priceController.text);
      String? notes = _notesController.text.isEmpty ? null : _notesController.text;

      //temp just for testing
      print('Name: $_selectedName, Place: $place, Date: $date, Price: $price, Reoccurring: $_isReoccurring, Notes: $notes');

      _placeController.clear();
      _dateController.clear();
      _priceController.clear();
      _notesController.clear();
      setState(() {
        _selectedName = null;
        _isReoccurring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: const Text('Enter Bill Information')),
      body: Padding (
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView (
          child: Form(
            key: _formKey,
            child: Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //dropdown box
                Row (
                  children: [
                    Expanded (
                      child: DropdownButtonFormField<String> (
                        decoration: const InputDecoration (
                          labelText: 'Select Name',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedName,
                        items: _names
                            .map((name) => DropdownMenuItem (
                          value: name,
                          child: Text(name),
                        ))
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

                    //checkbox
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

                //location entry box
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

                //date entry box
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a date' : null,
                ),
                const SizedBox(height: 12),

                //price entry box
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a price';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                //notes entry box (optional)
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),

                //submission button
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit Bill'),
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

