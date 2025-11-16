import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/calendar_event_model.dart';

class CalendarRepository {
  final SupabaseClient _supabase;

  CalendarRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<CalendarEventModel>> getEvents({DateTime? startDate, DateTime? endDate}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      var query = _supabase
          .from('calendar_events')
          .select()
          .eq('user_id', userId)
          .order('event_date', ascending: true);

      if (startDate != null) {
        query = query.gte('event_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('event_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query;
      final events = (response as List)
          .map((json) => CalendarEventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${events.length} calendar events');
      return events;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch calendar events', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching calendar events', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch calendar events', error: e);
    }
  }

  Future<CalendarEventModel?> getEventById(String id) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CalendarEventModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch calendar event', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching calendar event', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch calendar event', error: e);
    }
  }

  Future<CalendarEventModel> createEvent(CalendarEventModel event) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final eventData = event.toInsertJson();
      eventData['user_id'] = userId;

      final response = await _supabase
          .from('calendar_events')
          .insert(eventData)
          .select()
          .single();

      final created = CalendarEventModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Created calendar event: ${created.title}');
      return created;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to create calendar event', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating calendar event', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to create calendar event', error: e);
    }
  }

  Future<CalendarEventModel> updateEvent(CalendarEventModel event) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .update(event.toInsertJson())
          .eq('id', event.id)
          .select()
          .single();

      final updated = CalendarEventModel.fromJson(response as Map<String, dynamic>);
      AppLogger.info('Updated calendar event: ${updated.title}');
      return updated;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to update calendar event', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating calendar event', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to update calendar event', error: e);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _supabase
          .from('calendar_events')
          .delete()
          .eq('id', id);

      AppLogger.info('Deleted calendar event: $id');
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to delete calendar event', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting calendar event', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to delete calendar event', error: e);
    }
  }

  Future<List<CalendarEventModel>> getEventsByMonth(int year, int month) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('user_id', userId)
          .gte('event_date', startDate.toIso8601String().split('T')[0])
          .lte('event_date', endDate.toIso8601String().split('T')[0])
          .order('event_date', ascending: true);

      final events = (response as List)
          .map((json) => CalendarEventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${events.length} events for $year-$month');
      return events;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch monthly events', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching monthly events', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch monthly events', error: e);
    }
  }

  Future<List<CalendarEventModel>> getUpcomingEvents({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(message: 'User not authenticated');
      }

      final today = DateTime.now();

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('user_id', userId)
          .gte('event_date', today.toIso8601String().split('T')[0])
          .order('event_date', ascending: true)
          .limit(limit);

      final events = (response as List)
          .map((json) => CalendarEventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Fetched ${events.length} upcoming events');
      return events;
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to fetch upcoming events', error: e);
      throw DatabaseException(message: e.message, error: e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error fetching upcoming events', error: e, stackTrace: stackTrace);
      throw DatabaseException(message: 'Failed to fetch upcoming events', error: e);
    }
  }

  Stream<List<CalendarEventModel>> watchEvents({DateTime? startDate, DateTime? endDate}) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.error(const AuthenticationException(message: 'User not authenticated'));
    }

    return _supabase
        .from('calendar_events')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('event_date', ascending: true)
        .map((data) {
          var events = data.map((json) => CalendarEventModel.fromJson(json)).toList();

          if (startDate != null) {
            events = events.where((e) => e.eventDate.isAfter(startDate) || e.eventDate.isAtSameMomentAs(startDate)).toList();
          }

          if (endDate != null) {
            events = events.where((e) => e.eventDate.isBefore(endDate) || e.eventDate.isAtSameMomentAs(endDate)).toList();
          }

          return events;
        });
  }

  Future<Map<DateTime, List<CalendarEventModel>>> getEventsGroupedByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final events = await getEvents(startDate: startDate, endDate: endDate);
    final groupedEvents = <DateTime, List<CalendarEventModel>>{};

    for (final event in events) {
      final dateKey = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      );

      if (groupedEvents.containsKey(dateKey)) {
        groupedEvents[dateKey]!.add(event);
      } else {
        groupedEvents[dateKey] = [event];
      }
    }

    return groupedEvents;
  }
}
