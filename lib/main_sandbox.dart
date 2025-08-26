import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const CalendarPage(),
    );
  }
}

enum SelectionMode {
  single,
  range,
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String _selectionInfo = 'Select a date range';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7AD1A1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MonthCalendar(
                initialDate: DateTime(2024, 4),
                accentColor: const Color(0xFFABE3C2),
                selectionMode: SelectionMode.range,
                onRangeSelected: (start, end) {
                  setState(() {
                    _selectionInfo =
                        'Range: ${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
                  });

                  // You can also display a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected: ${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectionInfo,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    Key? key,
    this.onDateSelected,
    this.onRangeSelected,
    this.initialDate,
    this.accentColor = const Color(0xFFABE3C2),
    this.selectionMode = SelectionMode.range,
  }) : super(key: key);
  final Function(DateTime)? onDateSelected;
  final Function(DateTime, DateTime)? onRangeSelected;
  final DateTime? initialDate;
  final Color accentColor;
  final SelectionMode selectionMode;

  @override
  _MonthCalendarState createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();

    // Initialize with default selection if in range mode
    if (widget.selectionMode == SelectionMode.range) {
      _startDate = null;
      _endDate = null;
    } else {
      // For single selection mode, just set the start date
      _startDate = DateTime(_currentMonth.year, _currentMonth.month, 22);
      _endDate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildWeekdayHeader(),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM  yyyy').format(_currentMonth),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 40,
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);

    // Calculate first day of the grid (could be in previous month)
    // In most of Europe, weeks start on Monday (1) not Sunday (7)
    final int firstWeekday = firstDayOfMonth.weekday;

    // Calculate days from previous month to display
    final daysFromPreviousMonth = firstWeekday - 1;

    // Calculate the total days to display (including days from previous and next month)
    final totalDays = daysFromPreviousMonth + daysInMonth;
    final totalWeeks = (totalDays / 7).ceil();
    final totalCells = totalWeeks * 7;

    final List<DateTime> days = [];

    // Add days from previous month
    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);
    for (int i = previousMonth.day - daysFromPreviousMonth + 1; i <= previousMonth.day; i++) {
      days.add(DateTime(previousMonth.year, previousMonth.month, i));
    }

    // Add days from current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    // Add days from next month
    final nextDays = totalCells - days.length;
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    for (int i = 1; i <= nextDays; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == _currentMonth.month;

        // Check if this day is in the selected range
        bool isInRange = false;
        bool isStartDate = false;
        bool isEndDate = false;

        if (_startDate != null && _endDate != null) {
          // Normalize dates for comparison (no time component)
          final normalizedDay = DateTime(day.year, day.month, day.day);
          final normalizedStart = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          final normalizedEnd = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

          isStartDate = normalizedDay.isAtSameMomentAs(normalizedStart);
          isEndDate = normalizedDay.isAtSameMomentAs(normalizedEnd);
          isInRange =
              normalizedDay.isAfter(normalizedStart) && normalizedDay.isBefore(normalizedEnd);
        } else if (_startDate != null) {
          isStartDate = day.year == _startDate!.year &&
              day.month == _startDate!.month &&
              day.day == _startDate!.day;
        }

        return GestureDetector(
          onTap: () {
            if (!isCurrentMonth) return; // Don't allow selecting days from other months

            if (widget.selectionMode == SelectionMode.range) {
              _handleRangeSelection(day);
            } else {
              _handleSingleSelection(day);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isStartDate, isEndDate, isInRange, isCurrentMonth),
              borderRadius: BorderRadius.circular(10),
              border: (isStartDate || isEndDate)
                  ? Border.all(color: widget.accentColor.withAlpha(80), width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: isCurrentMonth ? Colors.black : Colors.grey,
                  fontWeight: (isStartDate || isEndDate) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(
    bool isStartDate,
    bool isEndDate,
    bool isInRange,
    bool isCurrentMonth,
  ) {
    if (!isCurrentMonth) return Colors.transparent;

    if (isStartDate || isEndDate) {
      return widget.accentColor;
    } else if (isInRange) {
      return widget.accentColor.withAlpha(50);
    }
    return Colors.transparent;
  }

  void _handleSingleSelection(DateTime day) {
    setState(() {
      _startDate = day;
      _endDate = null;
    });

    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day);
    }
  }

  void _handleRangeSelection(DateTime day) {
    setState(() {
      if (_startDate == null) {
        // First selection - set start date
        _startDate = day;
        _endDate = null;
      } else if (_endDate == null) {
        // Second selection - set end date
        // Ensure start date is before end date
        if (day.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = day;
        } else {
          _endDate = day;
        }

        // Notify callback of range selection
        if (widget.onRangeSelected != null) {
          widget.onRangeSelected!(_startDate!, _endDate!);
        }
      } else {
        // Reset selection and start new range
        _startDate = day;
        _endDate = null;
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }
}
