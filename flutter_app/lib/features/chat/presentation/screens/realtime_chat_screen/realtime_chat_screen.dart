import 'dart:async';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/connection_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/user_avatar.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/chat_item_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import 'dart:math' as math;
import '../../../../call/presentation/screens/call_screen.dart';
import '../../widgets/typing_indicator_widget.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/realtime_chat_page_controller.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/send_message_controller.dart';

class RealtimeChatScreenArgs {
  int userId;
  String fullName;
  RealtimeChatScreenArgs({required this.userId, required this.fullName});
}

class RealtimeChatScreen extends StatefulWidget {
  static const String route = '/chat';

  const RealtimeChatScreen({super.key});

  @override
  State<RealtimeChatScreen> createState() => _RealtimeChatScreenState();
}

class _RealtimeChatScreenState extends State<RealtimeChatScreen> {
  late final SendMessageController sendMessageController;
  final ScrollController scrollController = ScrollController();
  late final RealtimeChatPageController messagesController;
  late final RealtimeChatScreenArgs args;
  late final StreamSubscription<bool> keyboardSubscription;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    if (initialized) {
      print("args already initialized");
      return;
    }
    initialized = true;
    assert(ModalRoute.of(context)!.settings.arguments != null, "Please, inform the arguments. More info on https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#4-navigate-to-the-widget");
    args = ModalRoute.of(context)!.settings.arguments as RealtimeChatScreenArgs;

    messagesController = RealtimeChatPageController(userId: args.userId);
    sendMessageController = SendMessageController(text: '', receiverUserId: args.userId);

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE2E9F3), // Telegram Chat Background Color
        appBar: AppBar(
          backgroundColor: const Color(0xFF2481CC), // Telegram Blue
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: Row(
            children: [
              UserAvatar(fullName: args.fullName, size: 36, fontSize: 13),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "online",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            RequestCallIcon(userId: args.userId, iconData: Icons.call, videoCall: false, fullName: args.fullName),
            RequestCallIcon(userId: args.userId, iconData: Icons.videocam, videoCall: true, fullName: args.fullName),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ChatListItemEntity>>(
                          stream: messagesController.streamChatItems(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            goToBottom();

                            return ListView.builder(
                              clipBehavior: Clip.none,
                              controller: scrollController,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: index < snapshot.data!.length - 1
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.only(bottom: 15),
                                  child: ChatItemWidget(
                                    key: ValueKey(index),
                                    chatItem: snapshot.data![index],
                                  ),
                                );
                              },
                            );
                          }),
                    ),
                    
                    // Floating Input Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.grey),
                                    onPressed: () {},
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: sendMessageController,
                                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                                      decoration: const InputDecoration(
                                        hintText: 'Message',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onSubmitted: (_) => sendMessageController.sendMessage(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<bool>(
                            valueListenable: sendMessageController.hasTextToSendNotifier,
                            builder: (context, hasText, _) {
                              return GestureDetector(
                                onTap: () {
                                  if (hasText) {
                                    sendMessageController.sendMessage();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2481CC), // Telegram Blue
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hasText ? Icons.send : Icons.mic,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 10,
              child: ConnectionStatusWidget(),
            ),
          ],
        )
    );
  }

  int? get loggedUserId => getIt.get<AuthRepo>().loggedUserId;

  bool sentByLoggedUser(ChatListItemEntity data) => (data is MessageChatListItemEntity && data.message.senderUserId == loggedUserId) && data is! TypingIndicatorWidget;

  void goToBottom() {
    for (int i=1;i<=8;i++){
      Future.delayed(Duration(milliseconds: i * 50), (){
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }
}

class RequestCallIcon extends StatelessWidget {
  final int userId;
  final bool videoCall;
  final IconData iconData;
  final String fullName;

  const RequestCallIcon({required this.userId, required this.iconData, required this.videoCall, required this.fullName, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData, size: 22, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pushNamed(ScreenRoutes.requestCall,
            arguments: CallScreenArgs(
              remoteUserId: userId,
              callDirection: CallDirection.requestingCall,
              videoCall: videoCall,
              remoteUserFullName: fullName,
            )
        );
      },
    );
  }
}


