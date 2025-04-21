import 'package:pack/services/service.dart';

class UserPreferences extends IBaseModel {
  final bool darkMode;
  final String language;
  final Map<String, dynamic> settings;

  const UserPreferences({
    this.darkMode = false,
    this.language = 'en',
    this.settings = const {},
    super.id,
  });

  @override
  List<Object?> get props => [darkMode, language, settings];

  static final UserPreferences _empty = UserPreferences(
    darkMode: false,
    settings: {},
    id: '0',
    language: 'en',
  );

  UserPreferences empty() => UserPreferences._empty;

  bool isEmpty() => this == _empty;
}
