import 'package:flutter/material.dart';
import 'package:healthy_cook/components/colors_theme_fix.dart';
import 'package:healthy_cook/components/edit_profile_form.dart';
import 'package:healthy_cook/components/recipe_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'HealthyCook',
            style: TextStyle(fontSize: 20),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              EditProfileForm(),
              SizedBox(
                height: 30,
              ),
              RecipeList(),
            ],
          ),
        ));
  }
}
