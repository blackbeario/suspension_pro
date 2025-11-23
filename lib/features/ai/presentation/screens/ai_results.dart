import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/ai/domain/models/ai_response.dart';
import 'package:suspension_pro/features/bikes/domain/models/setting.dart';
import 'package:suspension_pro/core/providers/service_providers.dart';
import 'package:suspension_pro/core/prompts/prompts.dart';
import 'package:suspension_pro/core/utilities/helpers.dart';

class AiResultsDialog extends ConsumerStatefulWidget {
  const AiResultsDialog({
    Key? key,
    required this.weight,
    required this.year,
    required this.bikeId,
    required this.forkName,
    this.shockName,
    required this.trailConditions,
  });

  final String weight, year, bikeId, forkName, trailConditions;
  final String? shockName;

  @override
  ConsumerState<AiResultsDialog> createState() => _AiResultsDialogState();
}

class _AiResultsDialogState extends ConsumerState<AiResultsDialog> {
  late String responseChoices;
  final openAI = OpenAI.instance.build(
    token: getEnv('OPEN_API'),
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30), connectTimeout: const Duration(seconds: 30)),
    enableLog: true,
  );
  Setting? response;
  FormatException? responseErr;
  late String prompt;

  Future<ChatCTResponse?> chatComplete() async {
    // Here's the money logic. The app must determine what settings the fork/shock have.
    // Either the app needs to look up each fork/shock and determine what settings are available,
    // or have an internal library class that is manually updated. Online resources may be unreliable,
    // especially for ChatGPT. An internal class is going to be way more reliable and requires no
    // data retrieval, therefore no additional cost and X times more performant.

    // Alternatively, we could put checkboxes on the fork/shock forms and have the user SELECT
    // which setting options the component has when adding a bike. Hmmmm!!! Interesting!!!

    if (widget.shockName != null) {
      prompt = Prompt(
        weight: widget.weight,
        year: widget.year,
        bikeId: widget.bikeId,
        forkName: widget.forkName,
        trailConditions: widget.trailConditions).fullSuspensionPrompt(); // TODO add more options
    } else {
      prompt = Prompt(
        weight: widget.weight,
        year: widget.year,
        bikeId: widget.bikeId,
        forkName: widget.forkName,
        trailConditions: widget.trailConditions).hardTailWithFullForkPrompt(); // TODO add options
    }

    final request = ChatCompleteText(
      messages: [Messages(role: Role.user, content: prompt).toJson()],
      responseFormat: ResponseFormat.jsonObject,
      maxToken: 300,
      seed: 1,
      model: GptTurbo1106Model(),
    );

    final ChatCTResponse? response = await openAI.onChatCompletion(request: request);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0))),
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
            final ChatCTResponse? data = snapshot.data;
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

          return Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Suggested suspension settings for a ${widget.weight} pound rider on a ${widget.bikeId} mountain bike with a ${widget.forkName} ${widget.shockName != null ? 'and' : null} ${widget.shockName}, where the trail conditions are ${widget.trailConditions}:',
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                ),
                responseErr != null
                    ? Text(responseErr.toString())
                    : AiResponseWidget(response: response!, forkName: widget.forkName, shockName: widget.shockName),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SaveSettingButton(response: response!),
                    ElevatedButton(
                      child: Text('Dismiss'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SaveSettingButton extends ConsumerStatefulWidget {
  const SaveSettingButton({Key? key, required this.response});

  final Setting response;

  @override
  ConsumerState<SaveSettingButton> createState() => _SaveSettingButtonState();
}

class _SaveSettingButtonState extends ConsumerState<SaveSettingButton> {
  final _settingNameController = TextEditingController();
  late Setting response;

  @override
  void initState() {
    super.initState();
    response = widget.response;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Save'),
      onPressed: () {
        // Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                child: Column(
                  children: [
                    TextFormField(
                      validator: (_settingNameController) {
                        if (_settingNameController == null || _settingNameController.isEmpty)
                          return 'Please enter setting name';
                        return null;
                      },
                      decoration: InputDecoration(hintText: 'setting name'),
                      controller: _settingNameController,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // HiveService().putIntoBox('settings', response!.id, response, true);
                        setState(() => response.id = _settingNameController.text);
                        final db = ref.read(databaseServiceProvider);
                        await db.updateSetting(response);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit'),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
