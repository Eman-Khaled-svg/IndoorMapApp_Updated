// offers_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String searchQuery = '';
  String selectedStore = '';

  // محاكاة العروض لكل متجر
  final Map<String, List<String>> storeOffers = {
    'Fashion Hub': [
      'خصم 30% على الملابس الشتوية 👗',
      'اشترِ 2 واحصل على الثالث مجاناً 🛍️',
    ],
    'Tech Center': [
      'خصم 20% على اللابتوبات 💻',
      'هاتف جديد + سماعات هدية 🎧',
    ],
    'Food Court': [
      'وجبة كومبو بخصم 15% 🍔',
      'اشترِ بيتزا واحصل على الثانية نصف السعر 🍕',
    ],
    'Pharmacy': [
      'خصم 10% على الفيتامينات 💊',
      'منتجات العناية بالبشرة 1+1 مجاناً 💄',
    ],
    'Kids Zone': [
      'تذكرة لعب + هدية مجانية 🧸',
      'خصم 25% على الألعاب التعليمية 🎲',
    ],
    'Cinema': [
      'تذكرة + فشار مجاناً 🎬',
      'خصم 40% على العروض الصباحية 🍿',
    ],
  };

  @override
  Widget build(BuildContext context) {
    // الفلترة حسب البحث والمتجر المختار
    final filteredStores = storeOffers.keys.where((store) {
      return store.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white, // ✅ الخلفية بيضاء
      appBar: AppBar(
        title: const Text('العروض'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
               style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'ابحث عن متجر...',
                hintStyle: const TextStyle(color: Colors.grey), 
                prefixIcon: const Icon(Icons.search, color: Color(0xFF87CEEB)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  selectedStore = ''; // لو بيبحث ينسى المتجر المختار
                });
              },
            ),

            const SizedBox(height: 15),

            // Filter Chips للمتاجر
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: storeOffers.keys.map((store) {
                  final isSelected = selectedStore == store;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(store),
                      selected: isSelected,
                      backgroundColor: Colors.white, // ✅ خلفية التاب العادي أبيض
                      selectedColor: const Color(0xFF87CEEB), // ✅ التاب المختار أزرق
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF87CEEB) : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedStore = store;
                          searchQuery = '';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // قائمة العروض
            Expanded(
              child: ListView(
                children: [
                  for (var store in (selectedStore.isNotEmpty
                      ? [selectedStore]
                      : filteredStores))
                    ...storeOffers[store]!.map((offer) => _buildOfferCard(store, offer)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String store, String offer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: ListTile(
        leading: const Icon(FontAwesomeIcons.tags, color: Color(0xFF87CEEB)),
        title: Text(
          offer,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('من: $store'),
      ),
    );
  }
}
