import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/frosted_widgets.dart';
import '../../data/models/calendar_event_model.dart';
import '../../data/repositories/calendar_repository.dart';

// Providers
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});

final calendarEventsProvider = FutureProvider<List<CalendarEventModel>>((ref) async {
  final repository = ref.watch(calendarRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month - 3, 1);
  final endDate = DateTime(now.year, now.month + 3, 0);
  return repository.getEvents(startDate: startDate, endDate: endDate);
});

final upcomingEventsProvider = FutureProvider<List<CalendarEventModel>>((ref) async {
  final repository = ref.watch(calendarRepositoryProvider);
  return repository.getUpcomingEvents(limit: 5);
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    final upcomingAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(calendarEventsProvider);
          ref.invalidate(upcomingEventsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Widget
              eventsAsync.when(
                data: (events) => _buildCalendarCard(events),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Failed to load calendar'),
                  ),
                ),
              ),

              // Selected Day Events
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: DateFormat('EEEE, MMMM d').format(_selectedDay!),
                      ),
                      const SizedBox(height: 12),
                      eventsAsync.when(
                        data: (events) {
                          final dayEvents = events.where((e) =>
                            e.eventDate.year == _selectedDay!.year &&
                            e.eventDate.month == _selectedDay!.month &&
                            e.eventDate.day == _selectedDay!.day
                          ).toList();

                          if (dayEvents.isEmpty) {
                            return FrostedCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_available,
                                        size: 40,
                                        color: FrostedHearthColors.inkLight,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No events scheduled',
                                        style: GoogleFonts.sourceSerif4(
                                          color: FrostedHearthColors.inkLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: dayEvents.map((event) =>
                              _EventCard(event: event, onTap: () => _showEventDetails(context, event))
                            ).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Failed to load events'),
                      ),
                    ],
                  ),
                ),

              // Upcoming Events Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Upcoming Events'),
                    const SizedBox(height: 12),
                    upcomingAsync.when(
                      data: (events) {
                        if (events.isEmpty) {
                          return EmptyState(
                            icon: Icons.calendar_today,
                            title: 'No upcoming events',
                            subtitle: 'Add events to keep track of your holiday plans',
                            actionText: 'Add Event',
                            onAction: () => _showAddEventDialog(context, ref),
                          );
                        }

                        return _TimelineView(events: events);
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load upcoming events'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarCard(List<CalendarEventModel> events) {
    List<CalendarEventModel> getEventsForDay(DateTime day) {
      return events.where((e) =>
        e.eventDate.year == day.year &&
        e.eventDate.month == day.month &&
        e.eventDate.day == day.day
      ).toList();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FrostedHearthColors.snow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TableCalendar<CalendarEventModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.dmMono(color: FrostedHearthColors.winterBerry),
          todayDecoration: BoxDecoration(
            color: FrostedHearthColors.ember.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: FrostedHearthColors.ember,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: FrostedHearthColors.spruce,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          defaultTextStyle: GoogleFonts.dmMono(fontSize: 14),
          selectedTextStyle: GoogleFonts.dmMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FrostedHearthColors.frostGold,
          ),
          todayTextStyle: GoogleFonts.dmMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FrostedHearthColors.ember,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: FrostedHearthColors.parchmentWarm,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: GoogleFonts.sourceSerif4(
            fontSize: 12,
            color: FrostedHearthColors.spruce,
          ),
          titleTextStyle: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: FrostedHearthColors.inkDark,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: FrostedHearthColors.spruce),
          rightChevronIcon: Icon(Icons.chevron_right, color: FrostedHearthColors.spruce),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.dmMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FrostedHearthColors.inkLight,
          ),
          weekendStyle: GoogleFonts.dmMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FrostedHearthColors.winterBerry.withOpacity(0.7),
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  void _showEventDetails(BuildContext context, CalendarEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FrostedHearthColors.snow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FrostedHearthColors.parchmentWarm,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FrostedHearthColors.ember.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event, color: FrostedHearthColors.ember),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(event.eventDate),
                        style: GoogleFonts.dmMono(
                          fontSize: 12,
                          color: FrostedHearthColors.inkMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (event.description != null) ...[
              const SizedBox(height: 20),
              Text(
                event.description!,
                style: GoogleFonts.sourceSerif4(
                  fontSize: 14,
                  color: FrostedHearthColors.inkMedium,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final repository = ref.read(calendarRepositoryProvider);
                      await repository.deleteEvent(event.id);
                      ref.invalidate(calendarEventsProvider);
                      ref.invalidate(upcomingEventsProvider);
                    },
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Event', style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    prefixIcon: Icon(Icons.event),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an event title')),
                  );
                  return;
                }

                final event = CalendarEventModel(
                  id: '',
                  userId: '',
                  title: titleController.text,
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  eventDate: selectedDate,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  final repository = ref.read(calendarRepositoryProvider);
                  await repository.createEvent(event);
                  ref.invalidate(calendarEventsProvider);
                  ref.invalidate(upcomingEventsProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event added successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add event: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FrostedCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: FrostedHearthColors.ember,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (event.eventTime != null)
                    Text(
                      event.eventTime!,
                      style: GoogleFonts.dmMono(fontSize: 12, color: FrostedHearthColors.inkLight),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: FrostedHearthColors.inkLight),
          ],
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final List<CalendarEventModel> events;

  const _TimelineView({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isToday = event.eventDate.year == DateTime.now().year &&
            event.eventDate.month == DateTime.now().month &&
            event.eventDate.day == DateTime.now().day;

        return IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isToday
                            ? FrostedHearthColors.ember
                            : FrostedHearthColors.spruce.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.eventDate.day.toString(),
                            style: GoogleFonts.dmMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? FrostedHearthColors.frostGold
                                  : FrostedHearthColors.spruce,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(event.eventDate),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 9,
                              color: isToday
                                  ? FrostedHearthColors.frostGold.withOpacity(0.8)
                                  : FrostedHearthColors.inkLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < events.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: FrostedHearthColors.ember.withOpacity(0.2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FrostedCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrostedHearthColors.inkDark,
                          ),
                        ),
                        if (event.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description!,
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 13,
                              color: FrostedHearthColors.inkMedium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
