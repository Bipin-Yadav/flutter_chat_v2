import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/message_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:intl/intl.dart';
import 'balloon_widget.dart';
import 'delay_animate_switcher.dart';

class MessageSideWidget extends StatelessWidget {
  final MessageEntity message;

  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;
  bool get isLeftSide => message.senderUserId != loggedUserId;

  const MessageSideWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {

    assert(message.sentAt != null || message.sendStatus != SendStatus.sendSuccessfully, 'SendStatus.sendSuccessfully can only be true if sentAt is not null');


    return BalloonWidget(
      isLeftSide: isLeftSide,
      centerChildConstraints: (currentConstraints) => BoxConstraints(
        minWidth: 0,
        maxWidth: currentConstraints.maxWidth * .43,
      ),
      centerChild: LayoutBuilder(
        builder: (context, constraints) {
          return IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      message.text,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (message.sendStatus == SendStatus.sendFailed)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 14),
                      ),
                    Text(
                      message.sentAt != null
                          ? DateFormat('HH:mm').format(message.sentAt!)
                          : "",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isLeftSide) ...[
                      const SizedBox(width: 4),
                      MessageStatusWidget(message: message),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

