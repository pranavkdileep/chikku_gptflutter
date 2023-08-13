import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() => runApp(ChikkuGPTApp());

class ChikkuGPTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chikku GPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.content, required this.isUser, required this.timestamp});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add(Message(content: text, isUser: true, timestamp: DateTime.now()));
    });
    final response = await http.get(Uri.parse('https://chkikkugpt.onrender.com/predict?prompt=$text'));
    final responseData = json.decode(response.body);
    setState(() {
      _messages.add(Message(content: responseData['response'], isUser: false, timestamp: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chikku GPT Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: _messages[index].isUser
                      ? Align(
                      alignment: Alignment.topRight,
                      child: MarkdownBody(data: _messages[index].content))
                      : Align(
                      alignment: Alignment.topLeft,
                      child: MarkdownBody(data: _messages[index].content)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}