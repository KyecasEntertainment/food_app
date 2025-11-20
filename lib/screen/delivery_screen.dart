import 'package:flutter/material.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  double selectedTip = 0;
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          // BACKGROUND CONTENT HERE
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
            child: _buildStatusCard(),
          ),

          // DRAGGABLE SLIDING PANEL
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.12,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildRiderInfo(),

                    const SizedBox(height: 20),

                    _buildChatBox(),

                    const SizedBox(height: 20),

                    _buildTipButtons(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // UI SECTIONS
  // -------------------------------

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF8E8E8E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "5 - 10 mins\nOrder is On\nthe Way",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image(
                image: AssetImage("assets/images/delivery.png"), 
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage("assets/images/rider.png"),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ariel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Motorbike",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatBox() {
    return TextField(
      controller: _chatController,
      decoration: InputDecoration(
        hintText: "Chat with your rider",
        prefixIcon: const Icon(Icons.message_outlined),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTipButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "💰 Tip Rider",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tipButton(5),
            _tipButton(10),
            _tipButton(20),
          ],
        ),
      ],
    );
  }

  Widget _tipButton(double amount) {
    bool isSelected = selectedTip == amount;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTip = amount;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(
          "₱${amount.toInt()}",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
