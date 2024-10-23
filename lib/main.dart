import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // For input formatters

void main() {
  runApp(MyApp());
}

// MyApp and HomePage
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telepark',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double carX = 150; // Starting x position of the car
  double carY = 175; // Starting y position of the car
  double angle = 0;
  bool navigating = false;
  bool paymentPromptVisible = false; // New flag to show Pay Now button
  String? destinationMessage = '';

  List<ParkingZone> parkingZones = [
    ParkingZone(x: 100, y: 450, isAvailable: true),
    ParkingZone(x: 200, y: 450, isAvailable: false),
    ParkingZone(x: 300, y: 450, isAvailable: true),
    ParkingZone(x: 400, y: 200, isAvailable: false),
    ParkingZone(x: 500, y: 200, isAvailable: true),
  ];

  String searchQuery = '';
  String? selectedLocation = '';
  int currentIndex = 0; // Track the selected bottom navigation index

  void startNavigation() {
    setState(() {
      navigating = true;
      destinationMessage = '';
    });

    int step = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (step < 10) {
          // Move down towards Chipotle
          carY += 25; // Adjust the value based on how much movement you want per second
        } else if (step < 15) {
          // Move right towards Chipotle
          carX += 90; // Adjust the value to simulate moving to the right
        } else if (step < 20) {
          // Move up to park above Chipotle
          carY += 5; // Continue moving up
        }

        // End navigation after 20 seconds
        if (step == 19) {
          navigating = false;
          destinationMessage = 'Location Reached!';
          paymentPromptVisible = true; // Show the "Pay Now" button when location is reached
          timer.cancel();
        }

        step++;
      });
    });
  }

  // Function to navigate to the Payment Screen
  void payForParking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingPaymentScreen(),
      ),
    ).then((value) {
      // Code to execute after returning from the payment screen
      setState(() {
        paymentPromptVisible = false; // Hide the "Pay Now" button after payment
      });
    });
  }

  void onBottomNavTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    if (index == 1) {
      // Navigate to Profile Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountPage()),
      );
    } else if (index == 2) {
      // Navigate to Points Page when lightning button is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PointsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Telepark')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for a location',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  selectedLocation = (value.toLowerCase().contains('chipotle')) ? "255 Main St, Cambridge, MA 02142" : null;
                });
              },
            ),
          ),
          if (selectedLocation != null && !navigating)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: startNavigation,
                child: Text('Start Navigation'),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: MapPainter(carX, carY, angle, parkingZones),
                ),
                Positioned(
                  left: 350,
                  top: 50,
                  child: selectedLocation != null
                      ? Column(
                    children: [
                      Text(
                        'Chipotle: $selectedLocation',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      if (destinationMessage!.isNotEmpty)
                        Text(
                          destinationMessage!,
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                    ],
                  )
                      : Container(),
                ),
              ],
            ),
          ),
          if (navigating)
            Center(child: CircularProgressIndicator()), // Loading indicator
          if (paymentPromptVisible)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: payForParking,
                child: Text('Pay Now: \$2.35 for 2 hours'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Points', // Lightning Button
          ),
        ],
        currentIndex: currentIndex,
        onTap: onBottomNavTapped,
      ),
    );
  }
}

// ParkingZone and MapPainter classes
class ParkingZone {
  final double x;
  final double y;
  final bool isAvailable;

  ParkingZone({required this.x, required this.y, required this.isAvailable});
}

class MapPainter extends CustomPainter {
  final double carX;
  final double carY;
  final double angle;
  final List<ParkingZone> parkingZones;

  MapPainter(this.carX, this.carY, this.angle, this.parkingZones);

  @override
  void paint(Canvas canvas, Size size) {
    Paint roadPaint = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.6), roadPaint);

    Paint lanePaint = Paint()..color = Colors.yellow;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, size.height * 0.5), Offset(i + 20, size.height * 0.5), lanePaint);
    }

    Paint greenPaint = Paint()..color = Colors.green;
    Paint redPaint = Paint()..color = Colors.red;

    // Draw Parking Zones
    for (var zone in parkingZones) {
      Paint zonePaint = zone.isAvailable ? greenPaint : redPaint;
      canvas.drawRect(Rect.fromLTWH(zone.x, zone.y, 50, 5), zonePaint);
    }

    // Draw the car
    canvas.save();
    canvas.translate(carX, carY);
    canvas.rotate(angle);
    Paint carPaint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(-15, -10, 30, 20), carPaint);
    canvas.drawCircle(Offset(-10, 10), 5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(10, 10), 5, Paint()..color = Colors.black);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Parking Payment Screen
class ParkingPaymentScreen extends StatefulWidget {
  @override
  _ParkingPaymentScreenState createState() => _ParkingPaymentScreenState();
}

class _ParkingPaymentScreenState extends State<ParkingPaymentScreen> {
  double totalAmount = 2.35;
  int userPoints = 0;
  int points = 0; // Track earned points
  Timer? countdownTimer;
  Duration remainingTime = Duration(hours: 1); // Start with 1 hour
  bool isPaid = false;
  bool isExtensionConfirmed = false; // To show "Pay Now" button for extended time
  TextEditingController extendTimeController = TextEditingController();

  // Function to start the countdown after payment is made
  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - Duration(seconds: 1);
        } else {
          countdownTimer?.cancel();
        }
      });
    });
  }

  // Function to simulate leaving early and adding points
  void leaveEarly() {
    if (countdownTimer != null) {
      countdownTimer?.cancel();
    }

    // Calculate time left and convert to hours for point calculation
    double hoursLeft = remainingTime.inMinutes / 60;
    int pointsEarned = (hoursLeft * 100).round();

    setState(() {
      userPoints += pointsEarned;
      points += pointsEarned; // Accumulate points in the new variable
      remainingTime = Duration.zero;
      totalAmount = 0; // Parking session ends
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Parking Ended'),
          content: Text('You earned $pointsEarned points for leaving early!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to extend parking time
  void extendTime(int extraHours) {
    setState(() {
      remainingTime += Duration(hours: extraHours); // Add extra hours to remaining time
      totalAmount += extraHours * 2.35; // Charge $2.35 per extra hour
      isExtensionConfirmed = true; // Show "Pay Now" button for extended time
    });
  }

  // Function to format remaining time in hours and minutes
  String formatTimeLeft() {
    if (remainingTime.inMinutes < 60) {
      return '${remainingTime.inMinutes} minutes';
    } else {
      int hours = remainingTime.inHours;
      int minutes = remainingTime.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Payment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the home screen
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Parking Icon
              Icon(Icons.local_parking, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              // Parking payment details
              Text(
                'Total Amount Due',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 20),
              // Display parking time left
              Text(
                'Parking Time Left: ${formatTimeLeft()}',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              SizedBox(height: 40),
              // Payment button
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isPaid = true;
                      startCountdown(); // Start countdown after payment
                    });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Payment Successful'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('You have paid \$$totalAmount for your parking.'),
                              SizedBox(height: 20),
                              // Extend Time Input after payment
                              TextField(
                                controller: extendTimeController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ], // Allow only digits
                                decoration: InputDecoration(
                                  labelText: 'Extend parking by (hours)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Extend Time'),
                              onPressed: () {
                                int extraHours = int.tryParse(extendTimeController.text) ?? 0;
                                if (extraHours > 0) {
                                  extendTime(extraHours);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                    child: Text('Pay Now', style: TextStyle(fontSize: 20)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Updated
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Display Pay Now button for extended time
              if (isExtensionConfirmed)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isExtensionConfirmed = false; // Reset the confirmation
                    });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Extended Time Payment Successful'),
                          content: Text('You have paid for your extended parking time.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                    child: Text('Pay Now for Extended Time', style: TextStyle(fontSize: 18)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Updated
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Leave Early Button
              ElevatedButton(
                onPressed: leaveEarly,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                  child: Text('Leave Early', style: TextStyle(fontSize: 20)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Updated
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Show total points earned from leaving early
              Text(
                'Total Points Earned: $points',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AccountPage and PointsPage (unchanged)
class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Name: John Doe', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: johndoe@email.com', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Phone Number: +1234567890', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Car Model: Tesla Model 3', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class PointsPage extends StatefulWidget {
  @override
  _PointsPageState createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int points = 500; // User starts with 500 points
  bool isRedeemed = false;

  // Method to handle redemption
  void redeem(int cost) {
    if (points >= cost) {
      setState(() {
        points -= cost;
        isRedeemed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Redeemed!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough points to redeem!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.flash_on, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              '$points Points',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Points',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: 4,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (BuildContext context, int index) {
                // Define different options for the four cards
                List<int> pointCosts = [500, 1000, 2000, 4000];
                List<String> timeDurations = [
                  '2 hours -- FREE parking',
                  '4 hours -- FREE parking',
                  '8 hours -- FREE parking',
                  '16 hours -- FREE parking'
                ];

                // Color based on index
                Color cardColor = index == 0
                    ? Colors.lightGreenAccent
                    : Colors.lightBlueAccent;

                return GestureDetector(
                  onTap: !isRedeemed && points >= pointCosts[index]
                      ? () => redeem(pointCosts[index])
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isRedeemed && index == 0
                          ? Colors.grey
                          : cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.electric_car, // Updated icon
                          size: 50,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${pointCosts[index]} points',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          timeDurations[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
