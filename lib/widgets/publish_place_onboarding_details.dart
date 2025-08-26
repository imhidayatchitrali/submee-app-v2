import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:submee/widgets/switch_option.dart';

import '../models/property.dart';

class PublishPlaceOnboardingDetails extends HookWidget {
  const PublishPlaceOnboardingDetails({
    super.key,
    required this.onChange,
    required this.basicsSelected,
  });
  final Function(PropertyBasics) onChange;
  final PropertyBasics basicsSelected;
  @override
  Widget build(BuildContext context) {
    final basics = useState<PropertyBasics>(basicsSelected);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCounter(
                context,
                'Guests',
                basics.value.guests,
                (value) {
                  basics.value = basics.value.copyWith(guests: value);
                  onChange(basics.value);
                },
              ),
              _buildCounter(
                context,
                'Bedrooms',
                basics.value.bedrooms,
                (value) {
                  basics.value = basics.value.copyWith(bedrooms: value);
                  onChange(basics.value);
                },
              ),
              _buildCounter(
                context,
                'Beds',
                basics.value.beds,
                (value) {
                  basics.value = basics.value.copyWith(beds: value);
                  onChange(basics.value);
                },
              ),
              _buildCounter(
                context,
                'Bathrooms',
                basics.value.bathrooms,
                (value) {
                  basics.value = basics.value.copyWith(bathrooms: value);
                  onChange(basics.value);
                },
              ),
              _buildCounter(
                context,
                'Roommates',
                basics.value.roommates,
                (value) {
                  basics.value = basics.value.copyWith(roommates: value);
                  onChange(basics.value);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SwitchOption(label: 'Parking spot', isSelected: false, onChange: (val) {}),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apartment size',
                      style: textTheme.bodyLarge,
                    ),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: basics.value.size > 0 ? basics.value.size.toString() : null,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          final valueParsed = double.tryParse(value) ?? 0;
                          basics.value = basics.value.copyWith(size: valueParsed);
                          onChange(basics.value);
                        },
                        decoration: const InputDecoration(
                          hintText: '0.0',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    String label,
    int value,
    Function(int) onChange,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyLarge,
          ),
          Row(
            children: [
              _buildCircularButton(
                icon: Icons.remove,
                onPressed: () {
                  if (value > 0) {
                    onChange(value - 1);
                  }
                },
              ),
              const SizedBox(width: 16),
              Text(
                value.toString(),
                style: textTheme.bodyLarge,
              ),
              const SizedBox(width: 16),
              _buildCircularButton(
                icon: Icons.add,
                onPressed: () {
                  onChange(value + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
