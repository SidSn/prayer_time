// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:adhan/adhan.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:test_app/notification_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late Timer _timer;

  late PrayerTimes _prayerTimesCurrentDay = PrayerTimes(
    Coordinates(35.52717748308125, -1.0212574005613488),
    DateComponents.from(DateTime.now()),
    CalculationMethod.karachi.getParameters(),
  );
  late PrayerTimes _prayerTimesSelectedDate = PrayerTimes(
    Coordinates(35.52717748308125, -1.0212574005613488),
    DateComponents.from(DateTime.now()),
    CalculationMethod.karachi.getParameters(),
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _calculatePrayerTimes(_selectedDate);
    _schedulePrayerTimeNotifications();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _calculatePrayerTimes(DateTime date) async {
    final coordinates = Coordinates(35.52717748308125,
        -1.0212574005613488); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final dateComponents = DateComponents.from(date);

    // Calculate prayer times for the current day
    final prayerTimesCurrentDay =
        PrayerTimes(coordinates, DateComponents.from(DateTime.now()), params);
    setState(() {
      _prayerTimesCurrentDay = prayerTimesCurrentDay;
    });

    // Calculate prayer times for the selected date
    final prayerTimesSelectedDate =
        PrayerTimes(coordinates, dateComponents, params);
    setState(() {
      _prayerTimesSelectedDate = prayerTimesSelectedDate;
    });
  }

  void _schedulePrayerTimeNotification(String prayerName, DateTime prayerTime) {
    // Schedule notification using NotificationService
    NotificationService.scheduleNotification(
      title: 'Prayer Time Reminder',
      body: 'It\'s time for $prayerName prayer.',
      scheduledDate: prayerTime,
    );
  }

  // Call this method to schedule notifications for all prayer times
  void _schedulePrayerTimeNotifications() {
    _schedulePrayerTimeNotification('Fajr', _prayerTimesSelectedDate.fajr);
    _schedulePrayerTimeNotification(
        'Sunrise', _prayerTimesSelectedDate.sunrise);
    _schedulePrayerTimeNotification('Dhuhr', _prayerTimesSelectedDate.dhuhr);
    _schedulePrayerTimeNotification(
        'Asr', _prayerTimesSelectedDate.asr.subtract(const Duration(hours: 1)));
    _schedulePrayerTimeNotification(
        'Maghrib', _prayerTimesSelectedDate.maghrib);
    _schedulePrayerTimeNotification('Isha', _prayerTimesSelectedDate.isha);
  }

  void _changeDate(int days) {
    final newDate = _selectedDate.add(Duration(days: days));
    setState(() {
      _selectedDate = newDate;
    });
    _calculatePrayerTimes(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Times'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF70D4BE),
                        Color(0xFF0BA484),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Next Prayer Time ',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white)),
                      Text(
                        DateFormat('hh:mm a').format(getNextPrayerTime()!),
                        style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                          _getTimeUntilNextPrayer() +
                              " Left until " +
                              _getNextPrayerName(),
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => _changeDate(-1),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => _changeDate(1),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    const middleIndex = 3;
                    final middleDate =
                        _selectedDate.add(Duration(days: index - middleIndex));
                    final date =
                        _selectedDate.add(Duration(days: index - middleIndex));

                    final isSelected = date.day == _selectedDate.day;

                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF237563), width: 1.0)
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = middleDate;
                            });
                            _calculatePrayerTimes(middleDate);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color(0xFF237563)
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('E').format(date),
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: isSelected
                                        ? const Color(0xFF237563)
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF70D4BE),
                        Color(0xFF0BA484),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          NotificationService.scheduleNotification(
                              title: 'title',
                              body: 'body',
                              scheduledDate: DateTime.now()
                                  .add(const Duration(seconds: 5)));
                        },
                        child: _prayerTimeCard(
                            'Fajr', _prayerTimesSelectedDate.fajr, 0),
                      ),
                      _prayerTimeCard(
                          'Sunrise', _prayerTimesSelectedDate.sunrise, 1),
                      _prayerTimeCard(
                          'Dhuhr', _prayerTimesSelectedDate.dhuhr, 2),
                      _prayerTimeCard(
                          'Asr',
                          _prayerTimesSelectedDate.asr
                              .subtract(const Duration(hours: 1)),
                          3),
                      _prayerTimeCard(
                          'Maghrib', _prayerTimesSelectedDate.maghrib, 4),
                      _prayerTimeCard('Isha', _prayerTimesSelectedDate.isha, 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _prayerTimeCard(String title, DateTime time, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.all(5),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(title),
        subtitle: Text(DateFormat.jm().format(time)),
      ),
    );
  }

  String _getTimeUntilNextPrayer() {
    final now = DateTime.now();
    DateTime nextPrayerTime;

    if (_prayerTimesCurrentDay == null) {
      return 'Loading...';
    }

    if (_prayerTimesCurrentDay.fajr.isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.fajr;
    } else if (_prayerTimesCurrentDay.sunrise.isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.sunrise;
    } else if (_prayerTimesCurrentDay.dhuhr.isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.dhuhr;
    } else if (_prayerTimesCurrentDay.asr
        .subtract(const Duration(hours: 1))
        .isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.asr;
    } else if (_prayerTimesCurrentDay.maghrib.isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.maghrib;
    } else if (_prayerTimesCurrentDay.isha.isAfter(now)) {
      nextPrayerTime = _prayerTimesCurrentDay.isha;
    } else {
      // If none of the prayer times are after the current time,
      // set the next prayer time to the Fajr of the next day
      nextPrayerTime = _prayerTimesCurrentDay.fajr.add(const Duration(days: 1));
    }

    final remainingTime = nextPrayerTime.difference(now);

    if (remainingTime.isNegative) {
      // If the remaining time is negative, it means the current time
      // is after all prayer times for the day
      return 'Next Prayer: ${_getNextPrayerName()}';
    } else {
      return _formatDuration(remainingTime);
    }
  }

  String _getNextPrayerName() {
    final now = DateTime.now();
    if (_prayerTimesCurrentDay.fajr.isAfter(now)) {
      return 'Fajr';
    } else if (_prayerTimesCurrentDay.sunrise.isAfter(now)) {
      return 'Sunrise';
    } else if (_prayerTimesCurrentDay.dhuhr.isAfter(now)) {
      return 'Dhuhr';
    } else if (_prayerTimesCurrentDay.asr
        .subtract(const Duration(hours: 1))
        .isAfter(now)) {
      return 'Asr';
    } else if (_prayerTimesCurrentDay.maghrib.isAfter(now)) {
      return 'Maghrib';
    } else if (_prayerTimesCurrentDay.isha.isAfter(now)) {
      return 'Isha';
    } else {
      return 'Fajr';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  DateTime? getNextPrayerTime() {
    final now = DateTime.now();

    if (_prayerTimesCurrentDay == null) {
      return null;
    }

    if (_prayerTimesCurrentDay.fajr.isAfter(now)) {
      return _prayerTimesCurrentDay.fajr;
    } else if (_prayerTimesCurrentDay.sunrise.isAfter(now)) {
      return _prayerTimesCurrentDay.sunrise;
    } else if (_prayerTimesCurrentDay.dhuhr.isAfter(now)) {
      return _prayerTimesCurrentDay.dhuhr;
    } else if (_prayerTimesCurrentDay.asr
        .subtract(const Duration(hours: 1))
        .isAfter(now)) {
      return _prayerTimesCurrentDay.asr.subtract(const Duration(hours: 1));
    } else if (_prayerTimesCurrentDay.maghrib.isAfter(now)) {
      return _prayerTimesCurrentDay.maghrib;
    } else if (_prayerTimesCurrentDay.isha.isAfter(now)) {
      return _prayerTimesCurrentDay.isha;
    } else {
      // If all prayer times for the day have passed,
      // return null or handle it according to your requirement
      return _prayerTimesCurrentDay.fajr.add(const Duration(days: 1));
    }
  }
}
