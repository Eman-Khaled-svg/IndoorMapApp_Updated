// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Security Settings`
  String get security_settings {
    return Intl.message(
      'Security Settings',
      name: 'security_settings',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Face ID`
  String get face_id_title {
    return Intl.message(
      'Sign in with Face ID',
      name: 'face_id_title',
      desc: '',
      args: [],
    );
  }

  /// `Use Face ID for quick access to the application`
  String get face_id_description {
    return Intl.message(
      'Use Face ID for quick access to the application',
      name: 'face_id_description',
      desc: '',
      args: [],
    );
  }

  /// `Auto-logout`
  String get auto_logout_title {
    return Intl.message(
      'Auto-logout',
      name: 'auto_logout_title',
      desc: '',
      args: [],
    );
  }

  /// `Automatically logout after 5 minutes of inactivity`
  String get auto_logout_description {
    return Intl.message(
      'Automatically logout after 5 minutes of inactivity',
      name: 'auto_logout_description',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password_title {
    return Intl.message(
      'Change Password',
      name: 'change_password_title',
      desc: '',
      args: [],
    );
  }

  /// `Change your account password`
  String get change_password_description {
    return Intl.message(
      'Change your account password',
      name: 'change_password_description',
      desc: '',
      args: [],
    );
  }

  /// `Preferred Apps`
  String get preferred_apps {
    return Intl.message(
      'Preferred Apps',
      name: 'preferred_apps',
      desc: '',
      args: [],
    );
  }

  /// `Choose Navigation App`
  String get navigation_app_title {
    return Intl.message(
      'Choose Navigation App',
      name: 'navigation_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Select your preferred navigation application`
  String get navigation_app_description {
    return Intl.message(
      'Select your preferred navigation application',
      name: 'navigation_app_description',
      desc: '',
      args: [],
    );
  }

  /// `Choose Communication App`
  String get communication_app_title {
    return Intl.message(
      'Choose Communication App',
      name: 'communication_app_title',
      desc: '',
      args: [],
    );
  }

  /// `Select your preferred messaging application`
  String get communication_app_description {
    return Intl.message(
      'Select your preferred messaging application',
      name: 'communication_app_description',
      desc: '',
      args: [],
    );
  }

  /// `Applications`
  String get applications {
    return Intl.message(
      'Applications',
      name: 'applications',
      desc: '',
      args: [],
    );
  }

  /// `Location Services`
  String get location_services_title {
    return Intl.message(
      'Location Services',
      name: 'location_services_title',
      desc: '',
      args: [],
    );
  }

  /// `Allow apps to access your current location`
  String get location_services_description {
    return Intl.message(
      'Allow apps to access your current location',
      name: 'location_services_description',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
