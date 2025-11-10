import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

//bill class
class Bill extends StatelessWidget {
  final String name;
  final String place;
  final String date;
  final double price;

  const Bill({
    super.key,
    required this.name,
    required this.place,
    required this.date,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$name: $place", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text('\$${price.toStringAsFixed(2)}'),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final String accountName = "Cheapy and Spendy";
  final String firstName = "Cheapy";
  final String secondName = "Spendy";
  final double firstSpending = 240.21;
  final double secondSpending = 320.01;
  final List<double> firstMonthlyVales = const [1021.56, 1542.45, 648.10, 5460.90, 2121.22, 240.21];
  final List<double> secondMonthlyVales = const [721.56, 542.45, 462.10, 3541.90, 1548.22, 320.01];
  final List<String> currentViewableMonths = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final double graphMax = 10000.00;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Bill> bills = [
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
      Bill(name: 'Cheapy', place: 'starbucks', date: '2025-11-11', price: 10.50),
    ];



    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [

            //avatar and username
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: Text(
                accountName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Text(
              'Welcome $accountName',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            //chart title
            const Center(
              child: Text(
                'Monthly Spending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 0),

            //bar chart
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: graphMax,
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() < 0 || value.toInt() >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(labels[value.toInt()]),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(6, (i) =>
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: firstMonthlyVales[i], color: Colors.blue),
                          BarChartRodData(toY: secondMonthlyVales[i], color: Colors.red),
                        ],
                        barsSpace: 0,
                      )
                  ),
                ),
              ),
            ),

            //current month stats
            Column(
              children: [
                const Center(
                  child: Text(
                    'Your Spending This Month',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 0),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('\$${firstSpending.toStringAsFixed(2)}'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(secondName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('\$${secondSpending.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //scrollable lower box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: bills.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: bills[i],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

