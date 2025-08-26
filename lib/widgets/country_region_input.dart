import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/constant.dart';

class CountryRegionInput extends HookWidget {
  const CountryRegionInput({
    super.key,
    required this.onCountryChanged,
  });
  final Function(String code, String dialCode) onCountryChanged;

  @override
  Widget build(BuildContext context) {
    final selectedCountry = useState<String?>(null);
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedCountry.value != null ? primaryColor : const Color(0xFFB0B0B0),
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCountry.value,
            hint: const Text(
              'Country/Region',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade400,
              ),
            ),
            items: countries.map((country) {
              return DropdownMenuItem<String>(
                value: country['code'],
                child: Text(
                  '${country['name']} (${country['dialCode']})',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              selectedCountry.value = value;
              if (value != null) {
                final country = countries.firstWhere((c) => c['code'] == value);
                onCountryChanged.call(value, country['dialCode'] ?? '');
              }
            },
          ),
        ),
      ),
    );
  }
}
