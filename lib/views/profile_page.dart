import 'package:flutter/material.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              RecipeList(),
            ],
          ),
        ));
  }
}
