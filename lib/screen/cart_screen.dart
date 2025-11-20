import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/custom_top_bar.dart';
import 'package:food_app/database/product_list.dart';
import 'package:food_app/screen/search_screen.dart';

import 'package:food_app/database/user_accounts.dart';

class CartPage extends StatelessWidget {
  final UserAccounts? loggedInUser;
  const CartPage({super.key, this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cart', loggedInUser: loggedInUser),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  'Items in cart:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}