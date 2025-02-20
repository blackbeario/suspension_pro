import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/core/models/ai_response.dart';
import 'package:suspension_pro/core/services/db_service.dart';
import 'package:suspension_pro/core/utilities/helpers.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/models/setting.dart';

class OpenAiRequest extends StatefulWidget {
  OpenAiRequest({Key? key}) : super(key: key);

  @override
  _OpenAiRequestState createState() => _OpenAiRequestState();
}

class _OpenAiRequestState extends State<OpenAiRequest> {
  final db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _riderWeightController = TextEditingController();
  final _trailCondtionsController = TextEditingController();
  Bike? _selectedBike;
  late String _selectedForkName;
  late String _selectedShockName;
  final openAI = OpenAI.instance.build(
    token: getEnv('OPEN_API'),
    baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30)),
    enableLog: true,
  );
  Setting? response;
  FormatException? responseErr;
  Map jsonFormat = {
    "bike": "",
    "front_tire_pressure": "",
    "rear_tire_pressure": "",
    "notes": "",
    "suspension_settings": {
      "fork": {
        "sag": "",
        "air_pressure": "",
        "compression": {"high_speed": "", "low_speed": ""},
        "rebound": {"high_speed": "", "low_speed": ""},
        "volume_spacers": "",
      },
      "shock": {
        "sag": "",
        "springRate": "",
        "compression": {"high_speed": "", "low_speed": ""},
        "rebound": {"high_speed": "", "low_speed": ""},
        "volume_spacers": ""
      },
    },
  };

  Future<ChatCTResponse?> chatComplete() async {
    final String message =
        'Generate suspension settings for a ${_riderWeightController.text} pound rider on a ${_selectedBike!.yearModel} ${_selectedBike!.id} mountain bike with a $_selectedForkName and $_selectedShockName, riding on trail where the conditions are ${_trailCondtionsController.text}. Respond with json where the format is $jsonFormat.';

    final request = ChatCompleteText(
      messages: [Messages(role: Role.user, content: message).toJson()],
      responseFormat: ResponseFormat.jsonObject,
      maxToken: 300,
      seed: 1,
      model: GptTurbo1106Model(),
    );

    final ChatCTResponse? response =
        await openAI.onChatCompletion(request: request);
    return response;
  }

  @override
  void dispose() {
    _riderWeightController.dispose();
    super.dispose();
  }

  Widget _aiResultsDialog() {
    late String responseChoices;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0))),
      child: FutureBuilder(
        future: chatComplete(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SizedBox(
              height: 400,
              width: double.infinity,
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 400,
              width: double.infinity,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final ChatCTResponse? data = snapshot.data as ChatCTResponse?;
            for (var element in data!.choices) {
              responseChoices = element.message!.content;
              // print(responseChoices);

              try {
                var decodedResponse = jsonDecode(responseChoices);
                // responseChoices.transform(utf8.decoder).transform(json.decoder).listen((contents) {
                //   return dataDispose(contents);
                // });
                response = Setting.fromJson(decodedResponse);
              } on FormatException catch (e) {
                responseErr = e;
              }
            }
          }

          return ListView(
            shrinkWrap: true,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text('AI Suggestions'),
                  trailing: CupertinoButton(
                      child: Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Suggested suspension settings for a ${_riderWeightController.text} pound rider on a ${_selectedBike!.id} mountain bike trail where the conditions are ${_trailCondtionsController.text}',
                  style: TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ),
              responseErr != null
                  ? Text(responseErr.toString())
                  : AiResponseWidget(
                      response: response!,
                      forkName: _selectedForkName,
                      shockName: _selectedShockName),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton.filled(
                    child: Text('Save'),
                    onPressed: () {},
                  ),
                  CupertinoButton.filled(
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bikesList(List<Bike> bikes) {
    List<Widget> bikeNames = [];
    for (Bike bike in bikes) {
      bikeNames.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(bike.id),
      ));
    }
    return bikeNames;
  }

  _resetForm() {
    setState(() {
      _selectedBike = null;
      _riderWeightController.text = '';
      _trailCondtionsController.text = '';
    });
  }

  Widget _getBikes(List<Bike> bikes, BuildContext context) {
    return CupertinoButton.filled(
      child: Text('Select Bike'),
      onPressed: () {
        _resetForm();
        showCupertinoModalPopup(
          context: context,
          builder: (context) => SizedBox(
            width: double.infinity,
            height: 250,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(),
              children: _bikesList(bikes),
              onSelectedItemChanged: (value) {
                setState(() {
                  _selectedBike = bikes[value];
                  _selectedForkName = _selectedBike?.fork != null
                      ? (_selectedBike!.fork!.brand + ' ' + _selectedBike!.fork!.model)
                      : '';
                  _selectedShockName = _selectedBike?.shock != null
                      ? (_selectedBike!.shock!.brand + ' ' + _selectedBike!.shock!.model)
                      : '';
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Suspension Suggestions'),
      ),
      child: ConnectivityWidgetWrapper(
        alignment: Alignment.center,
        stacked: false,
        offlineWidget: Center(child: Text('You cannot buy credits while offline')),
        child: ListView(
          children: [
            Material(
              color: CupertinoColors.extraLightBackgroundGray,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Generate AI suspension suggestions by selecting a bike, entering trail conditions and rider weight.'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Text(
                            'Include type of trail, (ex: downhill, flow, jump line) and also conditions (ex: steep, wet, loose, etc.)'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: RichText(
                          text: TextSpan(
                            text: 'Results are returned from ',
                            style: DefaultTextStyle.of(context)
                                .style
                                .copyWith(fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'OpenAI',
                                style: new TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap =
                                      () => loadURL('https://openai.com/'),
                              ),
                              TextSpan(text: ' utilizing ChatGPT.'),
                            ],
                          ),
                        ),
                      ),

                      // Select Bike button
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        child: StreamBuilder<List<Bike>>(
                          stream: db.streamBikes(),
                          builder: (context, snapshot) {
                            List<Bike>? bikes = snapshot.data;
                            if (!snapshot.hasData || snapshot.hasError) {
                              return Text('Cannot fetch list of user bikes');
                            }
                            return _getBikes(bikes!, context);
                          },
                        ),
                      ),

                      if (_selectedBike != null)
                        Column(
                          children: [
                            Text(_selectedBike!.id),
                            if (_selectedForkName.isNotEmpty)
                              Text(_selectedForkName),
                            if (_selectedShockName.isNotEmpty)
                              Text(_selectedShockName),
                          ],
                        ),

                      // rider weight
                      if (_selectedBike != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextFormField(
                            validator: (_riderWeightController) {
                              if (_riderWeightController == null ||
                                  _riderWeightController.isEmpty)
                                return 'Please enter rider weight';
                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              // helperText: 'Rider Weight',
                              filled: true,
                              hoverColor: Colors.blue.shade100,
                              border: OutlineInputBorder(),
                              hintText: 'rider weight',
                            ),
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                            controller: _riderWeightController,
                            keyboardType: TextInputType.text,
                          ),
                        ),

                      // trail conditions
                      if (_riderWeightController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 4,
                            validator: (_trailCondtionsController) {
                              if (_trailCondtionsController == null ||
                                  _trailCondtionsController.isEmpty)
                                return 'Please describe trail conditions';
                              return null;
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              // helperText: 'Describe trail conditions.',
                              filled: true,
                              hoverColor: Colors.blue.shade100,
                              border: OutlineInputBorder(),
                              hintText: 'trail conditions',
                            ),
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                            controller: _trailCondtionsController,
                            keyboardType: TextInputType.text,
                          ),
                        ),

                      // submit widget
                      if (_riderWeightController.text.isNotEmpty &&
                          _trailCondtionsController.text.isNotEmpty)
                        CupertinoButton(
                            disabledColor: CupertinoColors.quaternarySystemFill,
                            color: CupertinoColors.activeBlue,
                            child: Text('Get Suggestions',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                showCupertinoModalPopup(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => _aiResultsDialog());
                              }
                            }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
