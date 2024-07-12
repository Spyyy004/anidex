// import 'package:anidex/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String animalName;
//
//   ChatScreen({required this.animalName});
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   bool _isTyping = false;
//   List<String> _messageSuggestions = [
//     "Tell me about your habitat.",
//     "What do you eat?",
//     "Are you a social animal?",
//     "Tell me about your favorite activities.",
//         "What predators do you have to watch out for?",
//         "How do you protect yourself from danger?",
//         "Can you mimic any sounds?",
//         "What's your favorite food?",
//         "Do you migrate? Where to and why?",
//         "How do you communicate with other animals?",
//         "Can you show me any special skills or behaviors?",
//         "Tell me about your family or group structure.",
//         "What challenges do you face in your environment?"
//   ];
//   List<String> _usedSuggestions = []; // Track used suggestions
//
//   @override
//   void initState() {
//     super.initState();
//     // Initial welcome message from the animal
//     _messages.add(ChatMessage(
//       text: "Hello, I'm ${widget.animalName}. Ask me anything!",
//       isUserMessage: false,
//     ));
//   }
//
//   void _sendMessage(String message) async {
//     if (message.isEmpty) return;
//
//     setState(() {
//       _messages.add(ChatMessage(
//         text: message,
//         isUserMessage: true,
//       ));
//       _isTyping = true; // Show typing indicator
//     });
//
//     final gemini = Gemini.instance;
//     try {
//       final response = await gemini.chat([
//         Content(
//           parts: [Parts(text: chatPrompt + "\n" + message)],
//           role: "user",
//         ),
//       ]);
//
//       setState(() {
//         _messages.add(ChatMessage(
//           text: response?.output ?? 'No response',
//           isUserMessage: false,
//         ));
//         _isTyping = false; // Hide typing indicator
//       });
//
//       // Remove the sent suggestion from the list
//       if (_messageSuggestions.contains(message)) {
//         _messageSuggestions.remove(message);
//         _usedSuggestions.add(message);
//       }
//
//       // Limit the number of suggestions shown to 3
//       if (_messageSuggestions.length < 3) {
//         _addNewSuggestion();
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add(ChatMessage(
//           text: "Failed to get response",
//           isUserMessage: false,
//         ));
//         _isTyping = false; // Hide typing indicator
//       });
//     } finally {
//       _controller.clear();
//     }
//   }
//
//   void _addNewSuggestion() {
//     // Find a suggestion that hasn't been used yet
//     String newSuggestion = _messageSuggestions.firstWhere(
//           (suggestion) => !_usedSuggestions.contains(suggestion),
//       orElse: () => "",
//     );
//
//     if (newSuggestion.isNotEmpty) {
//       setState(() {
//         _messageSuggestions.add(newSuggestion);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Talk to ${scannedAnimal}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessageBubble(_messages[index]);
//               },
//             ),
//           ),
//           _buildTypingIndicator(), // Show typing indicator if _isTyping is true
//           Wrap(
//             spacing: 8.0,
//             children: _messageSuggestions.getRange(0, 3).map((suggestion) {
//               return _buildSuggestionCard(suggestion);
//             }).toList(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(_controller.text);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage message) {
//     return Align(
//       alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//         padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         decoration: BoxDecoration(
//           color: message.isUserMessage ? Colors.blueAccent : Colors.grey[300],
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Text(
//           message.text,
//           style: TextStyle(color: message.isUserMessage ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuggestionCard(String suggestion) {
//     return ActionChip(
//       label: Text(suggestion),
//       onPressed: () {
//         _sendMessage(suggestion); // Send message when suggestion is tapped
//         // Replace used suggestion with a new one
//         setState(() {
//           _messageSuggestions.remove(suggestion);
//           _addNewSuggestion();
//         });
//       },
//     );
//   }
//
//   Widget _buildTypingIndicator() {
//     if (_isTyping) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 10,
//               height: 10,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//               ),
//             ),
//             SizedBox(width: 8),
//             Text('Typing...'),
//           ],
//         ),
//       );
//     } else {
//       return SizedBox.shrink();
//     }
//   }
// }
//
// class ChatMessage {
//   final String text;
//   final bool isUserMessage;
//
//   ChatMessage({required this.text, required this.isUserMessage});
// }


import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  final String animalName;

  ChatScreen({required this.animalName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  List<String> _messageSuggestions = [
    "Tell me about your habitat.",
    "What do you eat?",
    "Are you a social animal?",
    "Tell me about your favorite activities.",
    "What predators do you have to watch out for?",
    "How do you protect yourself from danger?",
    "Can you mimic any sounds?",
    "What's your favorite food?",
    "Do you migrate? Where to and why?",
    "How do you communicate with other animals?",
    "Can you show me any special skills or behaviors?",
    "Tell me about your family or group structure.",
    "What challenges do you face in your environment?"
  ];
  List<String> _usedSuggestions = []; // Track used suggestions

  @override
  void initState() {
    super.initState();
    // Initial welcome message from the animal
    _messages.add(ChatMessage(
      text: "Hello, I'm ${widget.animalName}. Ask me anything!",
      isUserMessage: false,
    ));
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUserMessage: true,
      ));
      _isTyping = true; // Show typing indicator
    });

    final gemini = Gemini.instance;
    try {
      final response = await gemini.chat([
        Content(
          parts: [Parts(text: chatPrompt + "\n" + message)],
          role: "user",
        ),
      ]);

      setState(() {
        _messages.add(ChatMessage(
          text: response?.output ?? 'No response',
          isUserMessage: false,
        ));
        _isTyping = false; // Hide typing indicator
      });

      // Remove the sent suggestion from the list
      if (_messageSuggestions.contains(message)) {
        _messageSuggestions.remove(message);
        _usedSuggestions.add(message);
      }

      // Limit the number of suggestions shown to 3
      if (_messageSuggestions.length < 3) {
        _addNewSuggestion();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Failed to get response",
          isUserMessage: false,
        ));
        _isTyping = false; // Hide typing indicator
      });
    } finally {
      _controller.clear();
    }
  }

  void _addNewSuggestion() {
    // Find a suggestion that hasn't been used yet
    String newSuggestion = _messageSuggestions.firstWhere(
          (suggestion) => !_usedSuggestions.contains(suggestion),
      orElse: () => "",
    );

    if (newSuggestion.isNotEmpty) {
      setState(() {
        _messageSuggestions.add(newSuggestion);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk to ${widget.animalName}',style: header3Styles.merge(TextStyle(color: Colors.white)),),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildTypingIndicator(), // Show typing indicator if _isTyping is true
          _buildMessageSuggestions(), // Display suggestions in a user-friendly way
          _buildInputField(), // Input field for user messages
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.isUserMessage ? primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.text,
          style: subtitleStyles.merge(TextStyle(color: message.isUserMessage ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  Widget _buildMessageSuggestions() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: _messageSuggestions.getRange(0, 3).map((suggestion) {
          return _buildSuggestionCard(suggestion);
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion) {
    return ActionChip(
      backgroundColor: primaryColor,
      label: Text(
        suggestion,
        style: subtitleStyles.merge(TextStyle(color: Colors.white)),
      ),
      onPressed: () {
        _sendMessage(suggestion); // Send message when suggestion is tapped
        // Replace used suggestion with a new one
        setState(() {
          _messageSuggestions.remove(suggestion);
          _addNewSuggestion();
        });
      },
    );
  }

  Widget _buildTypingIndicator() {
    if (_isTyping) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 8),
            Text('Typing...'),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () {
              _sendMessage(_controller.text);
            },
            child: Icon(Icons.send, color: Colors.white),
            backgroundColor: primaryColor,
            elevation: 0,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}
