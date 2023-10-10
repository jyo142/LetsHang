import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
import 'package:letshang/models/hang_event_model.dart';

class GoogleApiService {
  static gapis.AuthClient getGoogleHttpClient(String googleApiAccessToken) {
    final gapis.AccessCredentials credentials = gapis.AccessCredentials(
      gapis.AccessToken(
        'Bearer',
        googleApiAccessToken,
        // TODO(kevmoo): Use the correct value once it's available from authentication
        // See https://github.com/flutter/flutter/issues/80905
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // We don't have a refreshToken
      <String>[
        CalendarApi.calendarReadonlyScope,
      ], //TODO
    );

    return gapis.authenticatedClient(http.Client(), credentials);
  }

  static Future<Events> getPrimaryGoogleCalendarEvents(
      gapis.AuthClient client) async {
    final calendarApi = CalendarApi(client);
    return await calendarApi.events.list("primary");
  }

  static Future<void> addGoogleCalendarEvent(
      gapis.AuthClient client, HangEvent hangEvent) async {
    final calendarApi = CalendarApi(client);
    calendarApi.events.insert(
        Event(
            summary: hangEvent.eventName,
            description: hangEvent.eventDescription,
            start: EventDateTime(dateTime: hangEvent.eventStartDateTime),
            end: EventDateTime(dateTime: hangEvent.eventEndDateTime)),
        "primary");
  }
}
