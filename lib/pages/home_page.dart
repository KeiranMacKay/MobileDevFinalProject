import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


//account class
class Account extends StatelessWidget {
  final String accountName;
  final List<String>? userNames;
  final List<List<double>>? userSpending;

  const Account({
    super.key,
    required this.accountName,
    this.userNames,
    this.userSpending,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


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
            Text(
              "$name: $place",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text('\$${price.toStringAsFixed(2)}'),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //account class call, if the database can just write directly to this it'll work perfectly
  final Account testAccount = const Account(
    accountName: "The cheapies",
    userNames: ["Cheapy", "Spendy", "Wastey", "Hoardy", "Greedy", "John"],
    userSpending: [
      [1021.56, 1542.45, 648.10, 5460.90, 2121.22],
      [721.56, 542.45, 462.10, 3541.90, 1548.22],
      [1212.44, 1212.11, 564.33, 752.44, 2143.55],
      [23.23, 54.45, 76.23, 11.11, 45.43],
      [1.1, 2.2, 3.3, 4.4, 5.5, 6.6],
      [1000.1, 1000.1, 1000.1, 1000.1, 1000.1],
    ],
  );

  final List<String> currentViewableMonths =
  const ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  final double graphMax = 10000.0;

  @override
  Widget build(BuildContext context) {
    //hook up database to this so that it writes bill within the database
    final List<Bill> bills = const [
      Bill(
        name: 'Cheapy',
        place: 'Starbucks',
        date: '2025-11-11',
        price: 10.50,
      ),
      Bill(
        name: 'Spendy',
        place: 'McDonalds',
        date: '2025-11-12',
        price: 15.00,
      ),
    ];

    final int peopleCount = testAccount.userNames?.length ?? 0;
    final int monthsCount = currentViewableMonths.length;

    //getting spacing right on name display box
    final double availableWidth =
        MediaQuery.of(context).size.width - 32;
    final double tileWidth = availableWidth / 2;

    Widget buildPersonTile(int index) {
      final name = testAccount.userNames?[index] ?? 'User';
      final lastMonthSpending =
          testAccount.userSpending?[index][monthsCount - 1] ?? 0.0;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            Text('\$${lastMonthSpending.toStringAsFixed(2)}'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: Text(
                testAccount.accountName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Welcome ${testAccount.accountName}',
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
            const Center(
              child: Text(
                'Monthly Spending',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 0),

            //bar chart updates dynamically, based on provided user data
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: graphMax,
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= monthsCount) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              currentViewableMonths[value.toInt()],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(monthsCount, (monthIndex) {
                    return BarChartGroupData(
                      x: monthIndex,
                      barRods: List.generate(peopleCount, (personIndex) {
                        final personSpending =
                            testAccount.userSpending?[personIndex][monthIndex] ??
                                0;
                        final color = Colors
                            .primaries[personIndex % Colors.primaries.length];
                        return BarChartRodData(
                          toY: personSpending,
                          color: color,
                        );
                      }),
                      barsSpace: 2,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 1),

            //values for the current month
            if (peopleCount > 0)
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
                  const SizedBox(height: 1),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    height: 60,
                    child: peopleCount == 1
                        ? buildPersonTile(0)
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: peopleCount,
                      itemExtent: tileWidth,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return buildPersonTile(index);
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 1),

            //transaction history, should show all transactions over all months
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
                          itemBuilder: (context, i) => Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 4),
                            child: bills[i],
                          ),
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
