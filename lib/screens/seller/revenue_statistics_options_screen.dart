import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/revenue_service.dart';

class RevenueStatisticsOptionsScreen extends StatefulWidget {
  final String loggedInUserEmail;

  RevenueStatisticsOptionsScreen({required this.loggedInUserEmail});
  @override
  _RevenueStatisticsOptionsScreenState createState() =>
      _RevenueStatisticsOptionsScreenState();
}

class _RevenueStatisticsOptionsScreenState
    extends State<RevenueStatisticsOptionsScreen> {
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Theo Ngày';
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late ValueNotifier<List<dynamic>> _selectedEvents;
  late DateTime _focusedDay;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _focusedDay = _selectedStartDate;
    _rangeStart = _selectedStartDate.subtract(Duration(days: 7));
    _rangeEnd = _selectedStartDate.add(Duration(days: 7));
    _selectedEvents = ValueNotifier(
        _getEventsForDateRange(_selectedStartDate, _selectedEndDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Thống Kê'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPeriod = 'Theo Nhiều Ngày';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range,
                        size: 25, color: Color.fromRGBO(58, 57, 57, 1.0)),
                    SizedBox(width: 10),
                    Text(
                      'Theo Nhiều Ngày',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 57, 57, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPeriod = 'Theo Tháng';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today,
                        color: Color.fromRGBO(58, 57, 57, 1.0)),
                    SizedBox(height: 8), // Thêm khoảng cách giữa Icon và Text
                    Text(
                      'Theo Tháng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 57, 57, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPeriod = 'Theo Năm';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event,
                        size: 25, color: Color.fromRGBO(58, 57, 57, 1.0)),
                    SizedBox(height: 8),
                    Text(
                      'Theo Năm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 57, 57, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedPeriod == 'Theo Nhiều Ngày')
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text('Chọn ngày bắt đầu: '),
                    ElevatedButton(
                      onPressed: () => _selectDate((date) {
                        setState(() {
                          _selectedStartDate = date;
                          if (_selectedEndDate.isBefore(_selectedStartDate)) {
                            _selectedEndDate = _selectedStartDate;
                          }
                          _selectedEvents.value = _getEventsForDateRange(
                              _selectedStartDate, _selectedEndDate);
                        });
                      }),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedStartDate),
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(58, 57, 57, 1.0)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Chọn ngày kết thúc: '),
                    ElevatedButton(
                      onPressed: () => _selectDate((date) {
                        setState(() {
                          _selectedEndDate = date;
                          _selectedEvents.value = _getEventsForDateRange(
                              _selectedStartDate, _selectedEndDate);
                        });
                      }),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedEndDate),
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(58, 57, 57, 1.0)),
                      ),
                    ),
                  ],
                ),
              if (_selectedPeriod == 'Theo Tháng')
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text('Chọn tháng và năm: '),
                    ElevatedButton(
                      onPressed: () => _selectMonth(context),
                      child: Text(
                        DateFormat('MM/yyyy')
                            .format(DateTime(_selectedYear, _selectedMonth)),
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(58, 57, 57, 1.0)),
                      ),
                    ),
                  ],
                ),
              if (_selectedPeriod == 'Theo Năm')
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text('Chọn năm: '),
                    ElevatedButton(
                      onPressed: () => _selectYear(),
                      child: Text(
                        DateFormat('yyyy').format(DateTime(_selectedYear)),
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(58, 57, 57, 1.0)),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _viewStatistics,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(72, 167, 245, 1.0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart,
                        color: Color.fromRGBO(58, 57, 57, 1.0)),
                    SizedBox(width: 8),
                    Text(
                      'Xem Thống Kê',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(58, 57, 57, 1.0),
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

  void _selectDate(Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && onDateSelected != null) {
      onDateSelected(pickedDate);
      _selectedEvents.value = _getEventsForDate(pickedDate);
    }
  }

  void _selectMonth(BuildContext context) async {
    DateTime? pickedMonth = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear,
          _selectedMonth), // Sử dụng _selectedMonth và _selectedYear
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.input,
      fieldHintText: 'MM/YYYY',
      errorFormatText: 'Nhập đúng định dạng MM/YYYY',
      errorInvalidText: 'Nhập đúng định dạng MM/YYYY',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedMonth != null) {
      setState(() {
        _selectedEvents.value = _getEventsForMonth(pickedMonth);
        _selectedMonth = pickedMonth.month;
        _selectedYear = pickedMonth.year;
      });
    }
  }

  void _selectYear() async {
    DateTime? pickedYear = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, 1, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.input,
      fieldHintText: 'YYYY',
      errorFormatText: 'Nhập đúng định dạng YYYY',
      errorInvalidText: 'Nhập đúng định dạng YYYY',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedYear != null && pickedYear.year != _selectedYear) {
      setState(() {
        _selectedYear = pickedYear.year;
        _selectedEvents.value = _getEventsForYear(_selectedYear);
      });
    }
  }

  void _viewStatistics() async {
    double revenue;

    switch (_selectedPeriod) {
      case 'Theo Nhiều Ngày':
        print(' $_selectedStartDate and $_selectedEndDate');

        if (_selectedStartDate.isAfter(_selectedEndDate)) {
          print('Lỗi: Ngày bắt đầu không thể lớn hơn ngày kết thúc');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ngày bắt đầu lớn hơn ngày kết thúc!'),
            ),
          );
          return;
        } else {
          if (_selectedStartDate == _selectedEndDate) {
            DateTime startDate = DateTime(_selectedStartDate.year,
                _selectedStartDate.month, _selectedStartDate.day);
            DateTime endDate = DateTime(_selectedEndDate.year,
                _selectedEndDate.month, _selectedEndDate.day, 23, 59, 59);

            revenue = await RevenueService()
                .calculateRevenue(widget.loggedInUserEmail, startDate, endDate);
          } else {
            DateTime startUtc = _selectedStartDate.toUtc();
            DateTime endOfDay = DateTime(_selectedEndDate.year,
                _selectedEndDate.month, _selectedEndDate.day, 23, 59, 59);
            revenue = await RevenueService()
                .calculateRevenue(widget.loggedInUserEmail, startUtc, endOfDay);

            print(
                'Viewing statistics for $_selectedPeriod: $startUtc to $endOfDay');
          }
        }
        break;

      case 'Theo Tháng':
        DateTime startOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
        DateTime endOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
        endOfMonth = DateTime(
            endOfMonth.year, endOfMonth.month, endOfMonth.day, 23, 59, 59);
        revenue = await RevenueService().calculateRevenue(
            widget.loggedInUserEmail, startOfMonth, endOfMonth);
        print(
            'Viewing statistics for $_selectedPeriod: $startOfMonth to $endOfMonth');
        break;

      case 'Theo Năm':
        DateTime startOfYear = DateTime(_selectedYear, 1, 1);
        DateTime endOfYear = DateTime(_selectedYear, 12, 31);
        endOfYear = DateTime(
            endOfYear.year, endOfYear.month, endOfYear.day, 23, 59, 59);
        revenue = await RevenueService()
            .calculateRevenue(widget.loggedInUserEmail, startOfYear, endOfYear);
        print(
            'Viewing statistics for $_selectedPeriod: $startOfYear to $endOfYear');
        break;

      default:
        revenue = 0.0; // Handle default case
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.show_chart),
              SizedBox(width: 8),
              Text('Doanh Thu'),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Khoảng thời gian: $_selectedPeriod'),
              if (_selectedPeriod == 'Theo Ngày')
                Text('Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
              if (_selectedPeriod == 'Theo Nhiều Ngày')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Từ: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate)}'),
                    Text(
                        'Đến: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate)}'),
                  ],
                ),
              if (_selectedPeriod == 'Theo Tháng')
                Text(
                    'Tháng: ${DateFormat('MM/yyyy').format(DateTime(_selectedYear, _selectedMonth))}'),
              if (_selectedPeriod == 'Theo Năm')
                Text('Năm: ${DateFormat('yyyy').format(_selectedStartDate)}'),
              SizedBox(height: 8),
              Text(
                  'Doanh thu: ${NumberFormat.currency(locale: 'vi').format(revenue)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getEventsForDateRange(DateTime startDate, DateTime endDate) {
    List<String> events = [];
    Map<DateTime, List<String>> eventsData = {
      DateTime(2023, 11, 20): ['Event A', 'Event B'],
      DateTime(2023, 11, 21): ['Event C', 'Event D'],
    };

    for (DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      if (eventsData.containsKey(date)) {
        events.addAll(eventsData[date]!);
      }
    }

    return events;
  }

  List<String> _getEventsForDate(DateTime date) {
    Map<DateTime, List<String>> eventsData = {
      DateTime(2023, 11, 20, 15, 26, 37): ['Event A', 'Event B'],
      DateTime(2023, 11, 21, 15, 26, 37): ['Event C', 'Event D'],
    };

    DateTime truncatedDate = DateTime(date.year, date.month, date.day);

    if (eventsData.containsKey(truncatedDate)) {
      return eventsData[truncatedDate]!;
    }

    return [];
  }

  List<String> _getEventsForMonth(DateTime month) {
    Map<DateTime, List<String>> eventsData = {
      DateTime(2023, 11, 20): ['Event A', 'Event B'],
      DateTime(2023, 11, 21): ['Event C', 'Event D'],
    };

    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

    List<String> events = [];

    for (DateTime date = startOfMonth;
        date.isBefore(endOfMonth.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      if (eventsData.containsKey(date)) {
        events.addAll(eventsData[date]!);
      }
    }

    return events;
  }

  List<String> _getEventsForYear(int year) {
    Map<DateTime, List<String>> eventsData = {
      DateTime(year, 11, 20): ['Event A', 'Event B'],
      DateTime(year, 11, 21): ['Event C', 'Event D'],
    };

    List<String> events = [];

    for (DateTime date in eventsData.keys) {
      if (date.year == year) {
        events.addAll(eventsData[date]!);
      }
    }

    return events;
  }
}
