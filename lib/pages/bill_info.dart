import 'dart:io';

import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class BillInfoPage extends StatelessWidget {
  final Expense expense;

  const BillInfoPage({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Information")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ownership
                const Text(
                  "Ownership",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  expense.name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // location
                const Text(
                  "Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  expense.place,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // date
                const Text(
                  "Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  expense.date,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // price
                const Text(
                  "Price",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${expense.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // reoccurring
                const Text(
                  "Reoccurring?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  expense.isRecurring ? "Yes" : "No",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // notes (optional)
                const Text(
                  "Notes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  (expense.notes == null || expense.notes!.trim().isEmpty)
                      ? "None"
                      : expense.notes!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // photo (optional)
                const Text(
                  "Photo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(

                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildPhotoWidget(expense.receiptUri),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // if no photo
  Widget _buildPhotoWidget(String? receiptUri) {
    if (receiptUri == null || receiptUri.isEmpty) {
      return const Center(
        child: Text(
          "No photo available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // if photo fetch error
    final file = File(receiptUri);
    if (!file.existsSync()) {
      return const Center(
        child: Text(
          "Photo file not found",
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        fit: BoxFit.cover,
      ),
    );
  }
}

