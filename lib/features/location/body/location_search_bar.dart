import 'package:flutter/material.dart';

Widget buildSearchBar(TextEditingController _searchController) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for your city',
        hintStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
      ),
    ),
  );
}
