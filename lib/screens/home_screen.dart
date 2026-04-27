import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/utils/ai_service.dart';
import 'package:dao_app/screens/photo_quote_screen.dart';
import 'package:dao_app/services/database_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String todayQuote = '道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。';
  bool _showAIExplanation = false;
  String aiExplanation = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _explanationStyle = 'default'; // default, concise, detailed, modern
  bool _hasFetchedExtraQuotes = false;
  File? _selectedImage; // 存储选择的照片

  List<ChatMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatLoading = false;

  // 动画控制器
  late AnimationController _refreshController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initQuotes();
    // 初始化动画控制器
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _chatMessages.add(ChatMessage(content: text, isUser: true));
      _isChatLoading = true;
    });
    _chatController.clear();

    _scrollToBottom();

    try {
      final response = await AIService.chat(text);
      setState(() {
        _chatMessages.add(ChatMessage(content: response, isUser: false));
        _isChatLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          content: '抱歉，发生了错误，请稍后重试。',
          isUser: false,
        ));
        _isChatLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 为聊天选择图片
  Future<void> _selectImageForChat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhotoQuoteScreen()),
    );
    if (result != null && result is File) {
      // 直接发送图片消息
      _sendImageMessage(result);
    }
  }

  // 发送图片消息
  Future<void> _sendImageMessage(File image) async {
    setState(() {
      _chatMessages.add(ChatMessage(content: 'image', isUser: true));
      _isChatLoading = true;
    });

    _scrollToBottom();

    try {
      // 调用AI服务处理图片
      final response = await AIService.chatWithImage(image);
      setState(() {
        _chatMessages.add(ChatMessage(content: response, isUser: false));
        _isChatLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          content: '抱歉，处理图片时发生了错误，请稍后重试。',
          isUser: false,
        ));
        _isChatLoading = false;
      });
    }

    _scrollToBottom();
  }

  // 初始化名言数据
  Future<void> _initQuotes() async {
    // 从数据库获取随机名言
    await _randomQuote();
  }

  // 随机选择一条名言
  Future<void> _randomQuote() async {
    try {
      final quote = await DatabaseService().getRandomQuote();
      if (quote != null) {
        setState(() {
          todayQuote = quote['content'] as String;
        });
      }
    } catch (e) {
      print('获取随机名言失败: $e');
    }
  }

  // 请求大模型补充名言
  Future<void> _fetchExtraQuotes() async {
    try {
      // 这里应该调用实际的大模型API
      // 暂时使用模拟数据
      final extraQuotes = [
        '挫其锐，解其纷，和其光，同其尘。',
        '湛兮，似或存。吾不知谁之子，象帝之先。',
        '天地不仁，以万物为刍狗；圣人不仁，以百姓为刍狗。',
        '天地之间，其犹橐龠乎？虚而不屈，动而愈出。',
        '多言数穷，不如守中。',
        '谷神不死，是谓玄牝。玄牝之门，是谓天地根。',
        '绵绵若存，用之不勤。',
        '天长地久。天地所以能长且久者，以其不自生，故能长生。',
        '是以圣人后其身而身先，外其身而身存。',
        '非以其无私邪？故能成其私。'
      ];
      
      // 添加到数据库
      final dbService = DatabaseService();
      for (var quote in extraQuotes) {
        await dbService.insertQuote(quote);
      }
      _hasFetchedExtraQuotes = true;
    } catch (e) {
      print('获取额外名言失败: $e');
    }
  }

  // 刷新名言
  Future<void> _refreshQuote() async {
    // 清除照片和解读状态
    setState(() {
      _selectedImage = null;
      _showAIExplanation = false;
      aiExplanation = '';
    });
    
    // 第一次刷新时，请求大模型补充名言
    if (!_hasFetchedExtraQuotes) {
      await _fetchExtraQuotes();
    }
    // 随机选择一条名言
    await _randomQuote();
  }

  // 构建刷新按钮
  Widget _buildRefreshButton() {
    return ElevatedButton(
      onPressed: () async {
        // 启动旋转动画
        _refreshController.forward(from: 0);
        // 执行刷新操作
        await _refreshQuote();
      },
      child: RotationTransition(
        turns: _rotationAnimation,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );
  }

  // 刷新解读
  void _refreshExplanation() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      final explanation = await AIService.getExplanation(todayQuote, style: _explanationStyle);
      setState(() {
        aiExplanation = explanation;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '获取AI解读失败，请稍后重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dao · 道'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日一言
            const Text('今日一言', style: AppTheme.titleStyle),
            const SizedBox(height: 16.0),
            
            // 显示选择的照片
            if (_selectedImage != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: kIsWeb
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('照片已选择', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
            
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.cardPadding),
                child: Text(
                  todayQuote,
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 按钮组：AI解读、刷新和照片
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_showAIExplanation) {
                        setState(() {
                          _showAIExplanation = false;
                        });
                      } else {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                          _errorMessage = '';
                        });
                        
                        try {
                          String quoteToExplain = todayQuote;
                          
                          // 如果有选择的照片，先根据照片生成道家真言
                          if (_selectedImage != null) {
                            quoteToExplain = await AIService.getQuoteFromImage(_selectedImage!);
                            setState(() {
                              todayQuote = quoteToExplain;
                            });
                          }
                          
                          // 然后解读生成的真言
                          final explanation = await AIService.getExplanation(quoteToExplain, style: _explanationStyle);
                          setState(() {
                            aiExplanation = explanation;
                            _showAIExplanation = true;
                          });
                        } catch (e) {
                          setState(() {
                            _hasError = true;
                            _errorMessage = '获取AI解读失败，请稍后重试';
                          });
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: _isLoading 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ) 
                      : Text(_showAIExplanation ? '收起解读' : 'AI解读'),
                  ),
                  const SizedBox(width: 16.0),
                  _buildRefreshButton(),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PhotoQuoteScreen()),
                      );
                      print('照片选择结果: $result');
                      if (result != null) {
                        print('结果类型: ${result.runtimeType}');
                        if (result is File) {
                          print('照片路径: ${result.path}');
                          setState(() {
                            _selectedImage = result;
                            print('照片已存储: $_selectedImage');
                          });
                        } else {
                          print('结果不是File类型');
                        }
                      } else {
                        print('没有选择照片');
                      }
                    },
                    child: const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 错误提示
            if (_hasError)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8.0),
                            Text('错误', style: AppTheme.subtitleStyle),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(_errorMessage, style: AppTheme.bodyStyle),
                      ],
                    ),
                  ),
                ),
              ),
            if (_hasError) const SizedBox(height: 24.0),

            // AI解释卡片
            if (_showAIExplanation && !_hasError)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                            const SizedBox(width: 8.0),
                            Text('AI解读', style: AppTheme.subtitleStyle),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(aiExplanation.isNotEmpty ? aiExplanation : '这句话的意思是：可以用言语表达的道，不是永恒的道；可以用名称界定的名，不是永恒的名。无是天地的本始，有是万物的根源。它强调了道的超越性和不可言说性，同时指出了有无相生的辩证关系。', style: AppTheme.bodyStyle),
                        const SizedBox(height: 12.0),
                        Text('AI生成内容', style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showAIExplanation && !_hasError) const SizedBox(height: 16.0),
            
            // 解读风格选择和刷新按钮
            if (_showAIExplanation && !_hasError)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 解读风格选择
                  DropdownButton<String>(
                    value: _explanationStyle,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _explanationStyle = newValue;
                          // 自动刷新解读
                          _refreshExplanation();
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'default',
                        child: Text('默认解读'),
                      ),
                      DropdownMenuItem(
                        value: 'concise',
                        child: Text('简洁版'),
                      ),
                      DropdownMenuItem(
                        value: 'detailed',
                        child: Text('详细版'),
                      ),
                      DropdownMenuItem(
                        value: 'modern',
                        child: Text('现代视角'),
                      ),
                    ],
                  ),
                  // 刷新按钮
                  IconButton(
                    onPressed: _refreshExplanation,
                    icon: const Icon(Icons.refresh),
                    tooltip: '刷新解读',
                  ),
                ],
              ),
            if (_showAIExplanation && !_hasError) const SizedBox(height: 24.0),

            // AI对话区域
            const Text('AI对话', style: AppTheme.subtitleStyle),
            const SizedBox(height: 16.0),
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _chatMessages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 48,
                                  color: AppTheme.accentColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '向我提问吧',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '我可以解答关于道教文化的问题',
                                  style: AppTheme.captionStyle,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _chatMessages.length + (_isChatLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _chatMessages.length && _isChatLoading) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '道小来正在思考...',
                                        style: AppTheme.captionStyle,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final message = _chatMessages[index];
                              return _buildChatBubble(message);
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppTheme.borderRadius),
                        bottomRight: Radius.circular(AppTheme.borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 图片选择按钮
                        GestureDetector(
                          onTap: _isChatLoading ? null : _selectImageForChat,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.image,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: '输入你的问题...',
                              hintStyle: AppTheme.captionStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendChatMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isChatLoading ? null : _sendChatMessage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isChatLoading ? Colors.grey : AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentColor,
              child: const Text(
                '道',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: message.content == 'image' && message.isUser
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '图片已发送',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isUser ? AppTheme.accentColor : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                        bottomRight: Radius.circular(message.isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : AppTheme.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}