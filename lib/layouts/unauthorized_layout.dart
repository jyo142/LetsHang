import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnAuthorizedLayout extends StatelessWidget {
  final Widget content;
  final Widget imageContent;
  final bool? allowGoBack;
  const UnAuthorizedLayout(
      {Key? key,
      required this.content,
      required this.imageContent,
      this.allowGoBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFECEEF4),
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Stack(children: [
                          if (allowGoBack ?? false) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF9BADBD),
                              ),
                              onPressed: () {
                                context.pop();
                              },
                            ),
                          ],
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [imageContent],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 6,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.elliptical(300, 50),
                                            topRight:
                                                Radius.elliptical(300, 50))),
                                    child: content),
                              ),
                            ],
                          )
                        ]),
                      ),
                    )))));
  }
}
