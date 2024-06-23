import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:partnersapp/presentation/chargeCollection/chargeAmount.dart';
import 'package:partnersapp/presentation/login_screen/login_screen.dart';
import 'package:partnersapp/presentation/my_bookings/end_selfie_screen.dart';

class ChargeAmountScreen extends StatefulWidget {
  final String docName;

  const ChargeAmountScreen({Key? key, required this.docName}) : super(key: key);

  @override
  State<ChargeAmountScreen> createState() => _ChargeAmountScreenState();
}

class _ChargeAmountScreenState extends State<ChargeAmountScreen> {
  // LIST OF THE ITEMS
  final List<ChargeAmountClass> optionsList = [];

  final TextEditingController partsController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController collectamountController = TextEditingController();

  final forkey = GlobalKey<FormState>();

  int initialQuantity = 1;
  double collectedAmount = 0;
  double income10 = 0;
  double income15 = 0;

  double totalPrice = 0;

  // Method to calculate total price of added items
  void updateTotalPrice() {
    totalPrice = 0;
    for (var item in optionsList) {
      totalPrice = totalPrice + item.amount.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.height * 0.03),
          child: Form(
            key: forkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.025),
                const Center(
                  child: CommonText(
                    text: 'Charges Collected',
                  ),
                ),
                SizedBox(height: size.height * 0.035),
                const Text(
                  'Total Collected Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.0025),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: collectamountController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      collectedAmount = double.parse(value);
                    } else {
                      collectedAmount = 0.0; // Or some default value
                    }
                    print("collectedAmount updated: $collectedAmount");
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Amount";
                    }
                    return null; // No error
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Total Collected Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: partsController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Part";
                          }
                          // // Add additional validation if needed
                          // return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter Spare Name',
                          labelStyle: TextStyle(
                              fontSize: 12), // Adjust the font size as needed
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Amount";
                          }
                          // // Add additional validation if needed
                          // return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter Spare Amount',
                          labelStyle: TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                InkWell(
                  onTap: () {
                    if (forkey.currentState!.validate()) {
                      setState(() {
                        optionsList.add(ChargeAmountClass(
                            partsName: partsController.text,
                            amount: double.parse(amountController.text) *
                                initialQuantity));

                        partsController.clear();
                        amountController.clear();

                        initialQuantity = 1;

                        updateTotalPrice();
                      });
                    }
                  },
                  child: Container(
                    height: size.height * 0.065,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black87,
                      border: Border.all(
                        width: size.width * 0.0025,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.015,
                        ),
                        const Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: optionsList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shadowColor: Colors.black,
                        elevation: 10,
                        child: ListTile(
                          title: Text(
                            "Part: ${optionsList[index].partsName.toUpperCase()}",
                          ),
                          subtitle: Text(
                            "Amount: ${optionsList[index].amount.toString()}",
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                optionsList.removeAt(index);
                                updateTotalPrice();
                              });
                            },
                            icon: const Icon(
                              CupertinoIcons.delete_simple,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  height: size.height * 0.065,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green.shade200,
                  ),
                  child: Center(
                    child: Text(
                      'SPARE PARTS TOTAL: $totalPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.01,
                ),
                SizedBox(height: size.height * 0.015),
                InkWell(
                  onTap: () {
                    if (collectamountController.text.isEmpty || double.parse(collectamountController.text) == 0) {
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'CONFIRM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            "Are you sure?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                style: const ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        ContinuousRectangleBorder())),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )),
                            SizedBox(height: 10),
                            ElevatedButton(
                                style: const ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        ContinuousRectangleBorder())),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Dialog(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        child: Center(
                                          child:
                                              CircularProgressIndicator(), // Show circular progress indicator
                                        ),
                                      );
                                    },
                                    barrierDismissible:
                                        false, // Prevent dismissing the dialog by tapping outside
                                  );
                                  print('hey $collectedAmount');
                                  await calculateIncome();
                                  await updateData(); // Call the updateData function

                                  Navigator.pop(
                                      context); // Close the progress indicator dialog

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EndSelfieScreen(
                                        docName: widget.docName,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                    color: Colors.green,
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: size.height * 0.065,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: collectamountController.text.isEmpty
                          ? Colors.grey
                          : Colors.black, // Adjust color based on condition
                      border: Border.all(
                        width: size.width * 0.0025,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'CONFIRM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> calculateIncome() async {
    double newVal = collectedAmount - totalPrice;
    income10 = 0.1 * newVal;
    income15 = 0.15 * newVal;
  }

  Future<void> updateData() async {
    print(collectedAmount);
    print("check");
    // Step 1: Fetch the user ID of the technician
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String technicianUserId = user.uid;

      CollectionReference technicianCollection =
          FirebaseFirestore.instance.collection('technicians');
      DocumentReference technicianDocRef = technicianCollection
          .doc(technicianUserId)
          .collection('serviceList')
          .doc(widget.docName);

      List<Map<String, dynamic>> optionsListData = [];

      for (var item in optionsList) {
        optionsListData.add(item.toMap());
      }

      await technicianDocRef.update({
        'optionsList': optionsListData,
        'collectedAmount': collectedAmount,
        'totalSpareAmount': totalPrice,
        'income10': income10,
        'income15': income15,
      });

      // Step 3: Fetch customerUserId and serviceId from technician's document
      DocumentSnapshot technicianDoc = await technicianDocRef.get();
      String customerUserId = technicianDoc['customerId'];
      String serviceId = technicianDoc['serviceId'];

      if (customerUserId.isNotEmpty) {
        // Step 4: Update document in customer's collection
        CollectionReference customerCollection =
            FirebaseFirestore.instance.collection('customers');
        DocumentReference customerDocRef = customerCollection
            .doc(customerUserId)
            .collection('serviceDetails')
            .doc(serviceId);

        await customerDocRef.update({
          'optionsList': optionsListData,
          'collectedAmount': collectedAmount,
          'totalSpareAmount': totalPrice,
          'income10': income10,
          'income15': income15,
        });
      }
    } else {
      // Handle the case where the user is not authenticated or does not exist
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));

      print('User not authenticated');
    }
  }
}

class CommonText extends StatelessWidget {
  final String text;

  const CommonText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
    );
  }
}
