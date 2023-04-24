import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? subscription;
  RemoteConfigUpdate? update;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              '+ Init, and fetch, then turn off net work and then listen'),
          const Text(
              '+ After that, turn on network and fetch again, cancel and listen the changes, you will see "PlatformException(firebase_remote_config, Unable to connect to the server. Check your connection and try again., null, null)" in the recordError Function'),
          const Text(
              '+ I think the problem here is the realtime remote configuration can\'t connect to the server after the network is back'),
          _ButtonAndText(
            defaultText: 'Not initialized',
            buttonText: 'Initialize',
            onPressed: () async {
              final FirebaseRemoteConfig remoteConfig =
                  FirebaseRemoteConfig.instance;
              await remoteConfig.setConfigSettings(
                RemoteConfigSettings(
                  fetchTimeout: const Duration(seconds: 10),
                  minimumFetchInterval: const Duration(hours: 1),
                ),
              );
              await remoteConfig.setDefaults(<String, dynamic>{
                'welcome': 'default welcome',
                'hello': 'default hello',
              });
              RemoteConfigValue(null, ValueSource.valueStatic);
              return 'Initialized';
            },
          ),
          _ButtonAndText(
            defaultText: 'No data',
            onPressed: () async {
              try {
                final FirebaseRemoteConfig remoteConfig =
                    FirebaseRemoteConfig.instance;
                // Using zero duration to force fetching from remote server.
                await remoteConfig.setConfigSettings(
                  RemoteConfigSettings(
                    fetchTimeout: const Duration(seconds: 10),
                    minimumFetchInterval: Duration.zero,
                  ),
                );
                await remoteConfig.fetchAndActivate();
                return 'Fetched: ${remoteConfig.getString('welcome')}';
              } on PlatformException catch (exception) {
                // Fetch exception.
                print(exception);
                return 'Exception: $exception';
              } catch (exception) {
                print(exception);
                return 'Unable to fetch remote config. Cached or default values will be '
                    'used';
              }
            },
            buttonText: 'Fetch Activate',
          ),
          _ButtonAndText(
            defaultText: update != null
                ? 'Updated keys: ${update?.updatedKeys}'
                : 'No data',
            onPressed: () async {
              try {
                final FirebaseRemoteConfig remoteConfig =
                    FirebaseRemoteConfig.instance;
                if (subscription != null) {
                  await subscription!.cancel();
                  setState(() {
                    subscription = null;
                  });
                  return 'Listening cancelled';
                }
                setState(() {
                  subscription = remoteConfig.onConfigUpdated.listen((event) {
                    setState(() {
                      update = event;
                    });
                  });
                });

                return 'Listening, waiting for update...';
              } on PlatformException catch (exception) {
                // Fetch exception.
                print(exception);
                return 'Exception: $exception';
              } catch (exception) {
                print(exception);
                return 'Unable to listen to remote config. Cached or default values will be '
                    'used';
              }
            },
            buttonText: subscription != null ? 'Cancel' : 'Listen',
          )
        ],
      ),
    );
  }
}

class _ButtonAndText extends StatefulWidget {
  const _ButtonAndText({
    Key? key,
    required this.defaultText,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  final String defaultText;
  final String buttonText;
  final Future<String> Function() onPressed;

  @override
  State<_ButtonAndText> createState() => _ButtonAndTextState();
}

class _ButtonAndTextState extends State<_ButtonAndText> {
  String? _text;

  // Update text when widget is updated.
  @override
  void didUpdateWidget(covariant _ButtonAndText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultText != oldWidget.defaultText) {
      setState(() {
        _text = widget.defaultText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Text(_text ?? widget.defaultText),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final result = await widget.onPressed();
              setState(() {
                _text = result;
              });
            },
            child: Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}
