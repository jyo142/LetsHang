import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final String? photoUrl;
  const ProfilePic({Key? key, required this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            photoUrl != null && photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Material(
                      color: Colors.grey,
                      child: Image.network(
                        photoUrl as String,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : const ClipOval(
                    child: Material(
                      color: Colors.grey,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
          ],
        )
      ],
    );
  }
}
