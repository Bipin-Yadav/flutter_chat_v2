import 'dart:developer';
import 'package:askless/domain/services/authenticate_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/center_content_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/connection_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/expanded_section_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/user_avatar.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/user_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/use_cases/listen_to_conversations.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/stream_users_to_talk.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/users_to_talk_to_controller.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/users_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/logout.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import 'package:intl/intl.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';

class RealtimeConversationsScreen extends StatefulWidget {
  static const String route = '/conversations';

  const RealtimeConversationsScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeConversationsScreen> createState() => _RealtimeConversationsScreenState();
}

class _RealtimeConversationsScreenState extends State<RealtimeConversationsScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool startedConversationsIsExpanded = true;
  bool allContactsIsExpanded = true;

  final usersToTalkToController = UsersToTalkToController();

  void _clearText() {
    setState(() {
      searchController.text = '';
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2481CC), // Telegram Blue
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Telegram',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              searchFocusNode.requestFocus();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<dartz.Either<Failure, UserEntity>>(
              future: getIt.get<UsersRepo>().readUser(getIt.get<AuthRepo>().loggedUserId!),
              builder: (context, snapshot) {
                String fullName = "Loading...";
                if (snapshot.hasData) {
                  snapshot.data!.fold(
                    (l) => fullName = "User",
                    (r) {
                      fullName = r.fullName;
                    },
                  );
                }
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2481CC),
                  ),
                  currentAccountPicture: UserAvatar(
                    fullName: fullName,
                    size: 70,
                    fontSize: 24,
                  ),
                  accountName: Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  accountEmail: const Text(
                    "Logged in",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
              title: const Text('Saved Messages'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                getIt.get<Logout>().call().then((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
                });
              },
            ),
          ],
        ),
      ),
      body: CenterContentWidget(
        withBackground: false,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search for conversations...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                onPressed: _clearText,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        StreamBuilder<List<ConversationEntity>>(
                          stream: getIt.get<ListenToConversationsWithMessages>().call(),
                          builder: (context, conversationsSnapshot) {
                            if (conversationsSnapshot.hasError) {
                              log("An error occurred on ListenToConversationsWithMessages: ${conversationsSnapshot.error ?? "null"}");
                              return Container();
                            }
                            if (!conversationsSnapshot.hasData || conversationsSnapshot.data!.isEmpty) {
                              return Container();
                            }
                            final conversations = conversationsSnapshot.data!.where((element) =>
                                element.lastMessage?.text.toLowerCase().contains(searchController.text.toLowerCase()) == true ||
                                element.user.fullName.toLowerCase().contains(searchController.text.toLowerCase()));

                            if (conversations.isEmpty) return Container();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Subtitle(
                                  title: 'Conversations (${conversations.length.toString()})',
                                  isExpanded: startedConversationsIsExpanded,
                                  toggleExpand: (expand) {
                                    setState(() {
                                      startedConversationsIsExpanded = expand;
                                    });
                                  },
                                ),
                                ExpandedSection(
                                  expand: startedConversationsIsExpanded,
                                  child: Column(
                                    children: [
                                      ...conversations.mapIndexed((index, conversation) => Column(
                                            children: [
                                              _ConversationItem(
                                                userId: conversation.user.userId,
                                                fullName: conversation.user.fullName,
                                                message: conversation.lastMessage,
                                                isTyping: conversation.isTyping,
                                                unreadMessagesAmount: conversation.unreadMessagesAmount,
                                              ),
                                              Divider(height: 1, indent: 82, endIndent: 16, color: Colors.grey[100]),
                                            ],
                                          )).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        StreamBuilder<List<UserEntity>>(
                          stream: usersToTalkToController.stream(),
                          builder: (context, snapshotContacts) {
                            if (snapshotContacts.hasError) {
                              log("An error occurred on ReadAllContacts: ${snapshotContacts.error ?? "null"}");
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    "An error occurred. Please try again later",
                                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            }
                            if (!snapshotContacts.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final contacts = snapshotContacts.data!
                                .where((element) => ("${element.firstName} ${element.lastName}")
                                    .toLowerCase()
                                    .contains(searchController.text.toLowerCase()))
                                .where((element) => element.userId != getIt.get<AuthenticateService>().userId);

                            if (contacts.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "No user to talk to",
                                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      searchController.text.isEmpty
                                          ? "Create another account to start chatting!"
                                          : "No user matches the search filter",
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Subtitle(
                                  title: 'Contacts (${contacts.length.toString()})',
                                  isExpanded: allContactsIsExpanded,
                                  toggleExpand: (expand) {
                                    setState(() {
                                      allContactsIsExpanded = expand;
                                    });
                                  },
                                ),
                                ExpandedSection(
                                  expand: allContactsIsExpanded,
                                  child: Column(
                                    children: [
                                      ...contacts.map((user) => Column(
                                            children: [
                                              _ConversationItem(
                                                userId: user.userId,
                                                fullName: user.fullName,
                                              ),
                                              Divider(height: 1, indent: 82, endIndent: 16, color: Colors.grey[100]),
                                            ],
                                          )).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 16,
              left: 16,
              child: Material(
                type: MaterialType.transparency,
                child: ConnectionStatusWidget(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2481CC), // Telegram Blue
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          searchFocusNode.requestFocus();
        },
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final int unreadMessagesAmount;
  final String fullName;
  final int userId;
  final bool isTyping;
  final MessageEntity? message;

  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;

  const _ConversationItem({
    required this.fullName,
    this.message,
    required this.userId,
    this.isTyping = false,
    this.unreadMessagesAmount = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ScreenRoutes.chat, arguments: RealtimeChatScreenArgs(userId: userId, fullName: fullName));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            UserAvatar(fullName: fullName, size: 50, fontSize: 18),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (message?.sentAt != null)
                        Text(
                          DateFormat('HH:mm').format(message!.sentAt!),
                          style: TextStyle(
                            color: unreadMessagesAmount > 0 ? const Color(0xFF2481CC) : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: isTyping
                            ? const Text(
                                'typing...',
                                style: TextStyle(
                                  color: Color(0xFF2481CC),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              )
                            : Text(
                                message?.text ?? "Start a conversation",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                      ),
                      if (unreadMessagesAmount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF08C239),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadMessagesAmount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String title;
  final ValueChanged<bool> toggleExpand;
  final bool isExpanded;

  const _Subtitle({Key? key, required this.title, required this.toggleExpand, required this.isExpanded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.1,
            ),
          ),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[500],
              size: 20,
            ),
            onPressed: () => toggleExpand(!isExpanded),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

