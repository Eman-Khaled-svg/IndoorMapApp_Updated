// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "applications": MessageLookupByLibrary.simpleMessage("Applications"),
    "auto_logout_description": MessageLookupByLibrary.simpleMessage(
      "Automatically logout after 5 minutes of inactivity",
    ),
    "auto_logout_title": MessageLookupByLibrary.simpleMessage("Auto-logout"),
    "change_password_description": MessageLookupByLibrary.simpleMessage(
      "Change your account password",
    ),
    "change_password_title": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "communication_app_description": MessageLookupByLibrary.simpleMessage(
      "Select your preferred messaging application",
    ),
    "communication_app_title": MessageLookupByLibrary.simpleMessage(
      "Choose Communication App",
    ),
    "face_id_description": MessageLookupByLibrary.simpleMessage(
      "Use Face ID for quick access to the application",
    ),
    "face_id_title": MessageLookupByLibrary.simpleMessage(
      "Sign in with Face ID",
    ),
    "location_services_description": MessageLookupByLibrary.simpleMessage(
      "Allow apps to access your current location",
    ),
    "location_services_title": MessageLookupByLibrary.simpleMessage(
      "Location Services",
    ),
    "navigation_app_description": MessageLookupByLibrary.simpleMessage(
      "Select your preferred navigation application",
    ),
    "navigation_app_title": MessageLookupByLibrary.simpleMessage(
      "Choose Navigation App",
    ),
    "preferred_apps": MessageLookupByLibrary.simpleMessage("Preferred Apps"),
    "security_settings": MessageLookupByLibrary.simpleMessage(
      "Security Settings",
    ),
  };
}
