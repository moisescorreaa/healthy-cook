import 'package:flutter/material.dart';

/// Foto do usuário, ou a imagem padrão quando ele não enviou uma.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.photoUrl, required this.radius});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/images/user.png');
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: radius,
      backgroundImage: photoUrl == null
          ? fallback
          : NetworkImage(photoUrl!) as ImageProvider,
      onBackgroundImageError: photoUrl == null ? null : (_, __) {},
    );
  }
}
