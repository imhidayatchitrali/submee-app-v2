import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TabSection extends HookWidget {
  const TabSection({
    required this.tabs,
    required this.onTabSelected,
    Key? key,
  }) : super(key: key);
  final List<String> tabs;
  final Function(int) onTabSelected;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final _selectedIndex = useState(0);
    return Row(
      children: List.generate(tabs.length, (index) {
        final bool hasRightDivider = index < tabs.length - 1;

        return Expanded(
          child: Row(
            children: [
              // Tab button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _selectedIndex.value = index;
                    onTabSelected(index);
                  },
                  child: Container(
                    child: Center(
                      child: Text(
                        tabs[index],
                        style: textTheme.displaySmall!.copyWith(
                          fontSize: 16,
                          fontWeight:
                              _selectedIndex.value == index ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Right divider
              if (hasRightDivider)
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.black,
                ),
            ],
          ),
        );
      }),
    );
  }
}
