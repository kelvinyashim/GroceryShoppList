import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/model/Categories.dart';

class GroceryItem {
 const GroceryItem({ required this.name, required this.quantity, required this.category, required this.id});
  final String id;
  final String name;
  final int quantity;
  final Category category;

 

  }

