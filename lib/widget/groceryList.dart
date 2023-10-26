import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/model/Categories.dart';
import 'package:shoppinglist/model/Grocery.dart';
import 'package:shoppinglist/widget/New.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
    isLoading;
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-6a589-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    print(response.body);

    if (response.statusCode >= 400) {
      setState(() {
        errorMessage =
            "The program ran into an error fetching data rom the server.";
      });
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.text == item.value['category'],
            orElse: () =>
                MapEntry(Categories.carbs, Category("", Colors.black)),
          )
          .value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = _loadedItems;
      isLoading = false;
    });
  }

  void _addItem() async {
    final response = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (response == null) {
      return;
    }
    setState(() {
      _groceryItems.add(response);
    });
  }

  void _removeItem(GroceryItem item) {
    final url = Uri.https(
        'flutter-prep-6a589-default-rtdb.firebaseio.com', 'shopping-list.json/${item.id}');
    http.delete(url);
 setState(() {
      _groceryItems.remove(item);
    });
    // final itemIndex = _groceryItems.indexOf(item);
    // ScaffoldMessenger.of(context).clearSnackBars;
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   elevation: 3,
    //   content: Text("Item remove"),
    //   action: SnackBarAction(
    //     label: "Undo",
    //     onPressed: () {
    //       _groceryItems.insert(itemIndex, item);
    //     },
    //   ),
    // ));
    // setState(() {
    //   _groceryItems.remove(item);
    // });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          background: Container(
            color: Theme.of(context).colorScheme.background,
          ),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      content = Center(child: Text(errorMessage!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
