// lib/models/user_settings_model.dart

class UserSettings {
  final String city;
  final String country;
  final bool darkMode;
  final String adzanSound; // 'mekah' | 'madinah' | 'lokal'
  final int reminderMinutes; // 5 | 10 | 15 | 20 | 30
  final bool vibration;
  final bool notificationsEnabled;
  final double? latitude;
  final double? longitude;

  const UserSettings({
    this.city = 'Yogyakarta',
    this.country = 'Indonesia',
    this.darkMode = true,
    this.adzanSound = 'mekah',
    this.reminderMinutes = 10,
    this.vibration = true,
    this.notificationsEnabled = true,
    this.latitude,
    this.longitude,
  });

  UserSettings copyWith({
    String? city,
    String? country,
    bool? darkMode,
    String? adzanSound,
    int? reminderMinutes,
    bool? vibration,
    bool? notificationsEnabled,
    double? latitude,
    double? longitude,
  }) => UserSettings(
    city: city ?? this.city,
    country: country ?? this.country,
    darkMode: darkMode ?? this.darkMode,
    adzanSound: adzanSound ?? this.adzanSound,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    vibration: vibration ?? this.vibration,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );

  bool get hasCoordinates => latitude != null && longitude != null;

  String get adzanSoundLabel {
    switch (adzanSound) {
      case 'mekah':   return 'Mekah';
      case 'madinah': return 'Madinah';
      case 'lokal':   return 'Lokal';
      default:        return adzanSound;
    }
  }

  String get reminderLabel => '$reminderMinutes menit sebelumnya';

  Map<String, dynamic> toMap() => {
    'city': city,
    'country': country,
    'darkMode': darkMode,
    'adzanSound': adzanSound,
    'reminderMinutes': reminderMinutes,
    'vibration': vibration,
    'notificationsEnabled': notificationsEnabled,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
    city: map['city'] ?? 'Yogyakarta',
    country: map['country'] ?? 'Indonesia',
    darkMode: map['darkMode'] ?? true,
    adzanSound: map['adzanSound'] ?? 'mekah',
    reminderMinutes: map['reminderMinutes'] ?? 10,
    vibration: map['vibration'] ?? true,
    notificationsEnabled: map['notificationsEnabled'] ?? true,
    latitude: map['latitude'],
    longitude: map['longitude'],
  );

  @override
  String toString() =>
      'UserSettings(city: $city, darkMode: $darkMode, reminder: ${reminderMinutes}m)';
}