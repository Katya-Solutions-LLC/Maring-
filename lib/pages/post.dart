import 'package:flutter/material.dart';
import 'package:maring/utils/color.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: colorPrimaryDark,
      
    );
  }
}