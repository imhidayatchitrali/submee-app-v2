import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({
    super.key,
    required this.onDateRangeChanged,
    this.startDateSelected,
    this.endDateSelected,
  });
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final DateTime? startDateSelected;
  final DateTime? endDateSelected;
  @override
  _CustomCalendarWidgetState createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _currentDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final List<String> _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void initState() {
    _currentDate = DateTime.now();
    _rangeStart = widget.startDateSelected;
    _rangeEnd = widget.endDateSelected;
    super.initState();
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + 1,
        _currentDate.day,
      );
    });
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month - 1,
        _currentDate.day,
      );
    });
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = date;
        _rangeEnd = null;
      } else {
        if (date.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = date;
        } else {
          _rangeEnd = date;
        }
      }
    });
    widget.onDateRangeChanged(_rangeStart, _rangeEnd);
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return date.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
        date.isBefore(_rangeEnd!.add(const Duration(days: 1)));
  }

  List<DateTime> _getDaysInMonth() {
    final first = DateTime(_currentDate.year, _currentDate.month, 1);
    final daysBefore = first.weekday - 1;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysAfter = 7 - last.weekday;
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return List.generate(
      lastToDisplay.difference(firstToDisplay).inDays + 1,
      (index) => firstToDisplay.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        border: Border.all(color: const Color(0xFF252525)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.chevron_left),
                ),
              ),
              Text(
                '${DateFormat('MMMM').format(_currentDate)} ${_currentDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            crossAxisCount: 7,
            children: _getDaysInMonth().map((date) {
              final bool isSelected = date == _rangeStart || date == _rangeEnd;
              final bool isInRange = _isInRange(date);
              final bool isCurrentMonth = date.month == _currentDate.month;
              final bool isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              return GestureDetector(
                onTap: () => _handleDateSelection(date),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : isInRange
                            ? primaryColor.withValues(alpha: 0.14)
                            : (isCurrentMonth ? Colors.white : null),
                    border: isSelected
                        ? Border.all(color: primaryColor, width: 2)
                        : isToday
                            ? Border.all(
                                color: primaryColor,
                                width: 1,
                              )
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isInRange
                                ? primaryColor
                                : isCurrentMonth
                                    ? Colors.black
                                    : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
