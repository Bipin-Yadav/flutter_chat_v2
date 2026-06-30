import 'package:askless/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/screens/content/register_content.dart';
import '../../../core/widgets/center_content_widget.dart';
import 'content/login_content.dart';


class LoginAndRegistrationScreen extends StatefulWidget {
  static const String route = '/login';

  const LoginAndRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LoginAndRegistrationScreen> createState() => _LoginAndRegistrationScreenState();
}

class _LoginAndRegistrationScreenState extends State<LoginAndRegistrationScreen> {
  final ValueNotifier<String?> notifyError = ValueNotifier<String?>(null);
  late LoginAndRegistrationContent content;
  String? successMessage;

  connectionChanged(ConnectionDetails connectionDetails) {
    print("Connection status is ${connectionDetails.status} ${connectionDetails.disconnectionReason == null ? "" : " disconnected because ${connectionDetails.disconnectionReason}"}");
  }

  @override
  void initState() {
    super.initState();
    AsklessClient.instance.addOnConnectionChangeListener(connectionChanged, immediately: true);

    final List<dynamic> goToLoginHelper = [];
    loginContent({String? email}) => LoginContent(email: email, notifyError: notifyError, goToLogin: (message, email) => (goToLoginHelper[0] as GoToLoginCallback)(message, email));
    goToLoginHelper.add(
        (message, email) => setState(() {
          content = loginContent(email: email,);
          successMessage = message;
        })
    );
    content = loginContent();
  }

  @override
  void dispose() {
    AsklessClient.instance.removeOnConnectionChangeListener(connectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            content.title,
            style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: CenterContentWidget(
          withBackground: false,
          child: Center(
            child: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2481CC).withOpacity(0.1),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: const Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Color(0xFF2481CC)),
                    ),
                    const SizedBox(height: 35),

                    content,

                    // error message
                    ValueListenableBuilder(
                        valueListenable: notifyError,
                        builder: (context, error, widget) => error == null || error.isEmpty
                            ? Container()
                            : Column(
                          children: [
                            separator,
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    border: Border.all(color: Colors.red[200]!),
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  error,
                                  style: TextStyle(color: Colors.red[900], fontSize: 14, fontWeight: FontWeight.w600),
                                )
                            )
                          ],
                        )
                    ),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            notifyError.value = null;
                            content = content.nextContent;
                          });
                        },
                        child: Text(
                          content.nextContent.title,
                          style: const TextStyle(
                            color: Color(0xFF2481CC),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    if(successMessage?.isNotEmpty == true)
                      ...[
                        const SizedBox(height: 20),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green[200]!),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              successMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.green[900], fontSize: 14, fontWeight: FontWeight.w600),
                            )
                        )
                      ],

                    const SizedBox(height: 50)
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}

const separator = SizedBox(height: 15,);


abstract class LoginAndRegistrationContent extends Widget {
  const LoginAndRegistrationContent({super.key});

  String get title;
  LoginAndRegistrationContent get nextContent;
}

