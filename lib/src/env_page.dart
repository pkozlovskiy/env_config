import 'package:env_config/env_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnvPage extends StatefulWidget {
  const EnvPage({super.key});

  @override
  State<EnvPage> createState() => _EnvPageState();
}

class _EnvPageState extends State<EnvPage> {
  final List<EnvWidget> _widgets = [];

  @override
  Widget build(BuildContext context) {
    var map = EnvConfig().environments;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => _reset(),
              icon: const Icon(Icons.settings_backup_restore)),
          IconButton(onPressed: () => _save(), icon: const Icon(Icons.save)),
        ],
      ),
      body: ListView.builder(
        itemCount: map.length,
        itemBuilder: (context, index) {
          var env = map.entries.elementAt(index).value;
          var widget = switch (env) {
            StringEnv env => StringEnvWidget(env),
            IntEnv env => IntEnvWidget(env),
            BoolEnv env => BoolEnvWidget(env),
          };
          _widgets.add(widget as EnvWidget);
          return widget;
        },
      ),
    );
  }

  void _save() {
    for (var element in _widgets) {
      element.save();
    }
    //TODO restart app if needed
  }

  void _reset() {
    EnvConfig().resetDefault();
    setState(() {});
    //TODO restart app if needed
  }
}

mixin EnvWidget {
  void save();
}

class StringEnvWidget extends StatelessWidget with EnvWidget {
  final StringEnv _env;
  final TextEditingController _controller;

  StringEnvWidget(this._env, {super.key})
      : _controller = TextEditingController(text: _env.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: _env.name.toString(),
          helperText: 'current value: ${_env.value.toString()}',
        ),
      ),
    );
  }

  @override
  void save() {
    _env.value = _controller.text;
  }
}

class IntEnvWidget extends StatelessWidget with EnvWidget {
  final IntEnv _env;
  final TextEditingController _controller;

  IntEnvWidget(this._env, {super.key})
      : _controller = TextEditingController(text: _env.value.toString());

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Enter new value",
          border: const OutlineInputBorder(),
          helperText: 'current value: ${_env.value.toString()}',
        ),
      ),
    );
  }

  @override
  void save() {
    _env.value = int.parse(_controller.text);
  }
}

// ignore: must_be_immutable
class BoolEnvWidget extends StatefulWidget with EnvWidget {
  final BoolEnv _env;
  bool _val;

  BoolEnvWidget(this._env, {super.key}) : _val = _env.value;

  @override
  State<BoolEnvWidget> createState() => _BoolEnvWidgetState();

  @override
  void save() {
    _env.value = _val;
  }
}

class _BoolEnvWidgetState extends State<BoolEnvWidget> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget._env.name),
      value: widget._val,
      onChanged: (bool value) {
        widget._val = value;
        setState(() {});
      },
    );
  }
}
