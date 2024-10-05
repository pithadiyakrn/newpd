import 'package:flutter/material.dart';

// Define your data model
class Category {
  final int id;
  final String name;

  Category(this.id, this.name);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Searchable showModalBottomSheet Example',
      home: SearchableBottomSheetExample(),
    );
  }
}

class SearchableBottomSheetExample extends StatefulWidget {
  @override
  _SearchableBottomSheetExampleState createState() => _SearchableBottomSheetExampleState();
}

class _SearchableBottomSheetExampleState extends State<SearchableBottomSheetExample> {
  // Prepare a list of categories
  List<Category> categories = [
    Category(1, 'Category 1'),
    Category(2, 'Category 2'),
    Category(3, 'Category 3'),
    Category(4, 'Category 4'),
    Category(5, 'Category 5'),
    // Add more categories as needed
  ];

  // Declare a variable to hold the selected category
  Category? selectedCategory;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered and sorted list of categories based on the search query
  List<Category> _filteredSortedCategories(String query) {
    List<Category> filteredCategories = categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Sort the filtered categories alphabetically
    filteredCategories.sort((a, b) {
      return a.name.compareTo(b.name);
    });

    return filteredCategories;
  }

  // Function to update selectedCategory?.name
  void _updateSelectedCategoryName(Category category) {
    setState(() {
      selectedCategory = category;
    });
  }

  // Function to show bottom sheet
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to occupy the full height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Adjust the height factor as needed
          child: CustomBottomSheet(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Select a Category'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild the bottom sheet
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredSortedCategories(_searchController.text).length,
                        itemBuilder: (context, index) {
                          final category = _filteredSortedCategories(_searchController.text)[index];
                          return ListTile(
                            title: Text(category.name),
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                              print('Selected ID: ${category.id}');
                              print('Selected Name: ${category.name}');
                              // Close the bottom sheet after selecting
                              Navigator.pop(context);
                              _updateSelectedCategoryName(category);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searchable showModalBottomSheet Example'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Category: ${selectedCategory?.name ?? 'None'}', // Display selected category's name
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0), // Add some spacing
          Text(
            'Selected ID: ${selectedCategory?.id ?? 'None'}', // Display selected category's ID
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              _showBottomSheet(context);
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedCategory?.name ?? 'Select a Category'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final Widget child;

  const CustomBottomSheet({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );
  }
}
