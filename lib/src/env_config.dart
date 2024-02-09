library env_config;

import 'package:shared_preferences/shared_preferences.dart';

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();

  factory EnvConfig() {
    return _instance;
  }

  EnvConfig._internal();

  final Map<String, AppEnv> _environment = {};

  Map<String, AppEnv> get environments => _environment;

  Future init(
      List<AppEnv> defaultFlavor, List<(String, List<AppEnv>)> flavors) async {
    for (var element in defaultFlavor) {
      _environment.putIfAbsent(element.name, () => element);
    }
  }

  T getValueByName<T>(Enum name) => _environment[name.name]?.value;

  getEnvByName(Enum name) => _environment[name.name];

  void resetDefault() {
    _environment.forEach((key, value) {
      value.value = value.initValue;
    });
  }
}

sealed class AppEnv<T> {
  final String name;
  final T defaultValue;

  T get initValue;

  T get value => _currentValue();

  set value(T val);

  late final SharedPreferences _sharedPrefs;

  T _currentValue();

  String get _envName => name;

  String get _currentKey => '_env_current_$name';

  AppEnv({required this.name, required this.defaultValue}) {
    SharedPreferences.getInstance().then((it) {
      _sharedPrefs = it;
    });
  }
}

class StringEnv extends AppEnv<String> {
  StringEnv({required super.name, super.defaultValue = ''});

  @override
  String get initValue =>
      String.fromEnvironment(_envName, defaultValue: defaultValue);

  @override
  String _currentValue() {
    var value = _sharedPrefs.getString(_currentKey);
    if (value == null) {
      value = initValue;
      this.value = value;
    }
    return value;
  }

  @override
  set value(String val) {
    _sharedPrefs.setString(_currentKey, val);
  }
}

class IntEnv extends AppEnv<int> {
  IntEnv({required super.name, super.defaultValue = 0});

  @override
  int get initValue =>
      int.fromEnvironment(_envName, defaultValue: defaultValue);

  @override
  int _currentValue() {
    var value = _sharedPrefs.getInt(_currentKey);
    if (value == null) {
      value = initValue;
      this.value = value;
    }

    return value;
  }

  @override
  set value(int val) {
    _sharedPrefs.setInt(_currentKey, val);
  }
}

class BoolEnv extends AppEnv<bool> {
  BoolEnv({required super.name, super.defaultValue = false});

  @override
  bool get initValue =>
      bool.fromEnvironment(_envName, defaultValue: defaultValue);

  @override
  bool _currentValue() {
    var value = _sharedPrefs.getBool(_currentKey);
    if (value == null) {
      value = initValue;
      this.value = value;
    }

    return value;
  }

  @override
  set value(bool val) {
    _sharedPrefs.setBool(_currentKey, val);
  }
}
