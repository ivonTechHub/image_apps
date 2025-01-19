import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetailsScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItemsFromPrefs();
  }

  // Load items from SharedPreferences
  Future<void> _loadItemsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('items');
    if (savedData != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  // Save items to SharedPreferences
  Future<void> _saveItemsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = json.encode(_items);
    await prefs.setString('items', encodedData);
  }

  void _addItem(Map<String, dynamic> newItem) {
    setState(() {
      _items.add(newItem);
    });
    _saveItemsToPrefs(); // Save the updated list
  }

  void _editItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      _items[index] = updatedItem;
    });
    _saveItemsToPrefs(); // Save the updated list
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItemsToPrefs(); // Save the updated list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                onSave: (newItem) => _addItem(newItem),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final title = item['title'];
          final price = item['price'];
          final images = item['images'] as List<dynamic>;

          return Card(
            child: ListTile(
              leading: images.isNotEmpty
                  ? Image.memory(
                      base64Decode(images[0]),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(title ?? 'No Title'),
              subtitle: Text(price != null ? '₹$price' : 'No Price'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemScreen(
                          initialData: item,
                          onSave: (updatedItem) =>
                              _editItem(index, updatedItem),
                        ),
                      ),
                    );
                  } else if (value == 'Delete') {
                    _deleteItem(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(item: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const AddItemScreen({Key? key, this.initialData, required this.onSave})
      : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Uint8List> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _priceController.text = widget.initialData!['price'] ?? '';
      final List<dynamic>? imageBytesList = widget.initialData!['images'];
      _selectedImages = imageBytesList != null
          ? imageBytesList
              .map((imageString) => base64Decode(imageString))
              .toList()
          : [];
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      List<Uint8List> imageBytesList = [];
      for (XFile file in pickedFiles) {
        Uint8List imageBytes = await file.readAsBytes(); // Correct method
        imageBytesList.add(imageBytes);
      }

      setState(() {
        _selectedImages.addAll(imageBytesList);
      });
    }
  }

  void _saveItem() {
    final Map<String, dynamic> itemData = {
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'images': _selectedImages.map((image) => base64Encode(image)).toList(),
    };
    widget.onSave(itemData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.memory(
                          _selectedImages[index],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveItem,
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
