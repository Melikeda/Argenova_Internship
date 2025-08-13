import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Veri Analiz Asistanı',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: ChatListPage(),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String id;

  ChatMessage({
    required this.message, 
    required this.isUser,
    DateTime? timestamp,
    String? id,
  }) : this.timestamp = timestamp ?? DateTime.now(),
       this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      id: json['id'],
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }

  ChatSession copyWith({
    String? title,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: this.id,
      title: title ?? this.title,
      createdAt: this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }
}

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatSession> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];
    
    setState(() {
      _chatSessions = sessionsJson
          .map((json) => ChatSession.fromJson(jsonDecode(json)))
          .toList();
      _chatSessions.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    });
  }

  Future<void> _saveChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _chatSessions.map((session) => jsonEncode(session.toJson())).toList();
    await prefs.setStringList('chat_sessions', sessionsJson);
  }

  void _createNewChat() async {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Yeni Sohbet',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      messages: [],
    );

    // Önce session'ı listeye ekle ve kaydet
    setState(() {
      _chatSessions.insert(0, newSession);
    });
    await _saveChatSessions();

    // Sonra chat sayfasına git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatSession: newSession,
          onSessionUpdated: _updateSession,
        ),
      ),
    );
  }

  void _openChat(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatSession: session,
          onSessionUpdated: _updateSession,
        ),
      ),
    );
  }

  void _updateSession(ChatSession updatedSession) {
    setState(() {
      final index = _chatSessions.indexWhere((s) => s.id == updatedSession.id);
      if (index != -1) {
        _chatSessions[index] = updatedSession;
      } else {
        // Eğer session listede yoksa ekle (güvenlik için)
        _chatSessions.add(updatedSession);
      }
      // Son mesaja göre sırala
      _chatSessions.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    });
    _saveChatSessions();
  }

  Future<void> _deleteChat(ChatSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sohbeti Sil'),
        content: Text('Bu sohbeti silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _chatSessions.removeWhere((s) => s.id == session.id);
      });
      _saveChatSessions();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Dün';
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Excel Veri Asistanı',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllChats();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tüm Sohbetleri Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _chatSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz sohbet yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yeni bir sohbet başlatın',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _chatSessions.length,
              itemBuilder: (context, index) {
                final session = _chatSessions[index];
                final lastMessage = session.messages.isNotEmpty 
                    ? session.messages.last.message 
                    : 'Henüz mesaj yok';

                return Dismissible(
                  key: Key(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Sohbeti Sil'),
                        content: Text('Bu sohbeti silmek istediğinizden emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Sil', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _chatSessions.removeAt(index);
                    });
                    _saveChatSessions();
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: Icon(
                        Icons.analytics,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      session.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(session.lastMessageAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            session.messages.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _openChat(session),
                    onLongPress: () => _deleteChat(session),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _clearAllChats() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tüm Sohbetleri Sil'),
        content: Text('Tüm sohbetleri silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _chatSessions.clear();
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_sessions');
    }
  }
}

class ChatPage extends StatefulWidget {
  final ChatSession chatSession;
  final Function(ChatSession) onSessionUpdated;

  ChatPage({
    required this.chatSession,
    required this.onSessionUpdated,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late List<ChatMessage> _messages;
  final ScrollController _scrollController = ScrollController();
  
  final Uri backendUri = Uri.parse("http://172.20.10.4:8000/sor");
  
  bool _loading = false;
  late AnimationController _animationController;
  late ChatSession _currentSession;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currentSession = widget.chatSession;
    _messages = List.from(_currentSession.messages);
    
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      message: "Merhaba! Excel verileriniz hakkında sorularınızı sorabilirsiniz. Size nasıl yardımcı olabilirim?",
      isUser: false,
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
    // Welcome message eklendiğinde de session'ı güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSession();
    });
  }

  void _updateSession() {
    _currentSession = _currentSession.copyWith(
      messages: List.from(_messages),
      lastMessageAt: _messages.isNotEmpty ? _messages.last.timestamp : DateTime.now(),
      title: _generateTitle(),
    );
    widget.onSessionUpdated(_currentSession);
  }

  String _generateTitle() {
    if (_messages.isEmpty) return 'Yeni Sohbet';
    
    final userMessages = _messages.where((m) => m.isUser).toList();
    if (userMessages.isEmpty) return 'Yeni Sohbet';
    
    final firstUserMessage = userMessages.first.message;
    final words = firstUserMessage.trim().split(' ');
    
    if (words.length <= 4) {
      return firstUserMessage;
    } else {
      return '${words.take(4).join(' ')}...';
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(message: message, isUser: true);
    setState(() {
      _messages.add(userMessage);
      _loading = true;
    });
    
    _scrollToBottom();
    _updateSession();

    try {
      final response = await http.post(
        backendUri,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({"soru": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botMessage = ChatMessage(
          message: data["cevap"] ?? "Cevap alınamadı.", 
          isUser: false
        );
        
        setState(() {
          _messages.add(botMessage);
        });
      } else {
        final errorMessage = ChatMessage(
          message: "Sunucu hatası: ${response.statusCode}", 
          isUser: false
        );
        setState(() {
          _messages.add(errorMessage);
        });
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        message: "Bağlantı hatası: Lütfen internet bağlantınızı kontrol edin.", 
        isUser: false
      );
      setState(() {
        _messages.add(errorMessage);
      });
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollToBottom();
      _updateSession();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMessage(ChatMessage msg, int index) {
    final isUser = msg.isUser;
    final showTimestamp = index == 0 || 
        _messages[index - 1].timestamp.difference(msg.timestamp).inMinutes.abs() > 5;
    
    return Column(
      children: [
        if (showTimestamp)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _formatTime(msg.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.deepPurple[100],
                    child: Icon(
                      Icons.smart_toy,
                      size: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Colors.deepPurple 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                if (isUser) ...[
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple[100],
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  SizedBox(width: 4),
                  _buildDot(1),
                  SizedBox(width: 4),
                  _buildDot(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = (_animationController.value + index * 0.2) % 1.0;
        final opacity = (animationValue < 0.5) ? 
            (animationValue * 2) : (2 - animationValue * 2);
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + opacity * 0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentSession.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              '${_messages.length} mesaj',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear_chat') {
                _clearCurrentChat();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sohbeti Temizle'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _loading) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index], index);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Excel verileriniz hakkında sorunuzu yazın...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (value) {
                        if (!_loading) {
                          sendMessage(value);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _loading ? Colors.grey : Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _loading
                        ? null
                        : () {
                            sendMessage(_controller.text);
                            _controller.clear();
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCurrentChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sohbeti Temizle'),
        content: Text('Bu sohbetteki tüm mesajları silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Temizle', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _messages.clear();
      });
      _addWelcomeMessage();
    }
  }
}

