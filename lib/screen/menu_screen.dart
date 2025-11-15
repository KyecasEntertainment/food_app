import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_app/custom_top_bar.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Menu'),
      body: Column(
        children: [
          //Search Bar
          _buildSearchBar(),

        ],
      )
    );
  }

  Widget _buildSearchBar(){
    return Container(
      padding: EdgeInsets.only(top: 50),
      alignment: Alignment.topCenter,
      child: Container(            
        height: 40,
        width: 250,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 160, 160, 160),
          borderRadius: BorderRadius.circular(30)
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: const Color.fromARGB(255, 99, 99, 99),
            ),
            hintText: 'Search',
            hintStyle: GoogleFonts.istokWeb(
              textStyle: TextStyle(
                color: const Color.fromARGB(255, 99, 99, 99),
                fontWeight: FontWeight.bold,
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCategory(){
    return Container(

    );
  }
}