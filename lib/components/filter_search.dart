import 'package:flutter/material.dart';

class FilterSearchComponent extends StatefulWidget {
  final Map<String, List<String>> categories;

  const FilterSearchComponent({super.key, required this.categories});

  @override
  State<FilterSearchComponent> createState() => _FilterSearchComponentState();
}

class _FilterSearchComponentState extends State<FilterSearchComponent> {
  final TextEditingController _searchController = TextEditingController();
  
  final Map<String, Set<String>> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    for (var key in widget.categories.keys) {
      _selectedOptions[key] = {};
    }
  }

  void _openFilterModal(String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFF5F2E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtrar por $category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider( color: Color(0xFFF7E18B) ),
                  ...widget.categories[category]!.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: _selectedOptions[category]?.contains(option),
                      activeColor: Color(0xFF4FA8FF),
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            _selectedOptions[category]?.add(option);
                          } else {
                            _selectedOptions[category]?.remove(option);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4FA8FF),
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Confirmar'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquise a entrega',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          )
        ),

        Wrap(
          spacing: 5.0,
          alignment: WrapAlignment.center,
          children: widget.categories.keys.map((category) {
            final int count = _selectedOptions[category]?.length ?? 0;
            final bool isSelected = count > 0;

            return FilterChip(
              label: Text(
                isSelected ? '$category ($count)' : category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _openFilterModal(category),
              selectedColor: Color(0xFF4FA8FF),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}