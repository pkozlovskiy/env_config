import 'package:env_config/env_config.dart';
import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({}); //set values here
    await SharedPreferences.getInstance();

    var envConfig = EnvConfig();
    envConfig.init([
      StringEnv(name: EnvName.stringEnv.name, defaultValue: 'string'),
      IntEnv(name: EnvName.intEnv.name, defaultValue: 123),
      BoolEnv(name: EnvName.boolEnv.name, defaultValue: true)
    ], []);
  });

  test('get default env value', () async {
    var envConfig = EnvConfig();

    expect(envConfig.getValueByName(EnvName.stringEnv), 'string');
    expect(envConfig.getValueByName(EnvName.intEnv), 123);
    expect(envConfig.getValueByName(EnvName.boolEnv), true);
  });

  test('set env value', () async {
    var envConfig = EnvConfig();

    envConfig.getEnvByName(EnvName.stringEnv).value = 'new';
    envConfig.getEnvByName(EnvName.intEnv).value = 321;
    envConfig.getEnvByName(EnvName.boolEnv).value = false;

    expect(envConfig.getValueByName(EnvName.stringEnv), 'new');
    expect(envConfig.getValueByName(EnvName.intEnv), 321);
    expect(envConfig.getValueByName(EnvName.boolEnv), false);
  });
}

enum EnvName {
  test,
  stringEnv,
  intEnv,
  boolEnv,
}
