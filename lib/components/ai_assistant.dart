import 'package:flutter/material.dart';

class AIAssistantDialog extends StatefulWidget {
  @override
  _AIAssistantDialogState createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final Map<String, dynamic> _inventory = {
    'Bakers': {'stock': 10, 'category': 'Biscuits', 'price': 5.00},
    'yeezy slides': {'stock': 14, 'category': 'Shoes', 'price': 100.00},
    'Mazoe': {'stock': 20, 'category': 'Groceries', 'price': 2.50},
    'Crinkles': {'stock': 18, 'category': 'Groceries', 'price': 0.50},
    'Mouse': {'stock': 98, 'category': 'Gadgets', 'price': 25.00},
    'Jordan 7': {'stock': 50, 'category': 'Shoes', 'price': 120.00},
    'Shirt': {'stock': 99, 'category': 'Clothes', 'price': 5.00},
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      _addBotMessage(
        "Hi there! I'm your inventory assistant. Need help with restocking or finding deals?",
      );
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'text': text, 'isUser': false});
      _isTyping = false;
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _controller.clear();
      _isTyping = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      _generateResponse(text);
    });
  }

  void _generateResponse(String userInput) {
    String response = "";
    final now = DateTime.now();
    final month = now.month;

    // Check low stock items
    final lowStockItems = _inventory.entries
        .where((item) => item.value['stock'] < 15)
        .map((item) => item.key)
        .toList();

    if (userInput.toLowerCase().contains('low stock') ||
        userInput.toLowerCase().contains('restock')) {
      if (lowStockItems.isNotEmpty) {
        response = "⚠️ Critical low stock items:\n";
        for (var item in lowStockItems) {
          response += "- ${item} (only ${_inventory[item]['stock']} left)\n";
        }

        if (lowStockItems.contains('Bakers')) {
          response +=
              "\n🍪 For Bakers biscuits, eBay has bulk packs (50 units) at 60% off!\n";
        }
        if (lowStockItems.contains('yeezy slides')) {
          response +=
              "\n👟 Yeezy slides restock alert: Amazon has similar slides at \$75 (25% off retail)\n";
        }
      } else {
        response = "All items have sufficient stock levels currently.";
      }

      response +=
          "\n🔥 Hot Deal: Nike/Adidas jerseys on Amazon from \$10 (80% off) - perfect for bundling with our shoes!";
    } else if (userInput.toLowerCase().contains('deal') ||
        userInput.toLowerCase().contains('discount')) {
      response = "💰 Current best deals from partners:\n"
          "1. Groceries: Amazon Pantry has 50% off bulk snacks (great for Mazoe/Crinkles)\n"
          "2. Shoes: eBay 'Buy 2 Get 1 Free' on sneakers (match with our Jordan 7s)\n"
          "3. Electronics: Logitech mice \$15 (40% off) - upgrade from our basic mouse\n"
          "4. Clothing: Basic tees \$3 each (60% off) - pair with our shirts";
    } else if (userInput.toLowerCase().contains('food') ||
        userInput.toLowerCase().contains('grocery')) {
      response = "🍎 Food item recommendations:\n"
          "- Bulk Mazoe orders: Walmart has 30% off case quantities\n"
          "- Crinkles alternative: Amazon has similar biscuits at \$0.30 each\n"
          "- New product: Protein bars trending (Amazon 50% off first order)";
    } else {
      response = "I can help with:\n"
          "- Low stock alerts (Bakers, yeezy slides are low!)\n"
          "- Best deals from Amazon/eBay\n"
          "- Seasonal recommendations\n"
          "- Inventory optimization\n\n"
          "Pro Tip: Nike jerseys are \$10 on Amazon right now - great margin if we bundle with shoes!";
    }

    _addBotMessage(response);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: Color(0xFF5CD2C6), size: 24),
                SizedBox(width: 10),
                Text('AI Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF363753),
                    )),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message['isUser']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message['isUser']
                            ? Color(0xFF5CD2C6).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text('Assistant is typing...',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about inventory...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF5CD2C6)),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _addUserMessage(_controller.text);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about inventory...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF5CD2C6)),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _addUserMessage(_controller.text);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) _addUserMessage(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
