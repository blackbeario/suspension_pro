import 'package:flutter/foundation.dart';
import 'package:suspension_pro/core/prompts/components.dart';

class Prompt {
  Prompt(
      {Key? key,
      required this.weight,
      required this.year,
      required this.bikeId,
      required this.forkName,
      required this.trailConditions,
      this.shockName});

  final String weight, year, bikeId, forkName, trailConditions;
  final String? shockName;

  String baseString() {
    return 'Generate suspension settings for a $weight pound rider on a $year $bikeId mountain bike with a $forkName ${shockName != null ? 'and' : ''} ${shockName}, riding on trail where the conditions are $trailConditions.';
  }

  String fullSuspensionPrompt() {
    return '${baseString()} Respond with json where the format is $fullSuspension.';
  }

  String fullSuspensionWithCompressionPrompt() {
    return '$baseString Respond with json where the format is $fullSuspensionWithCompression.';
  }

  String fullSuspensionWithReboundPrompt() {
    return '$baseString Respond with json where the format is $fullSuspensionWithRebound.';
  }

  String hardTailWithFullForkPrompt() {
    return '$baseString Respond with json where the format is $hardTailWithFullFork.';
  }

  String hardTailWithCompressionPrompt() {
    return '$baseString Respond with json where the format is $hardTailWithCompression.';
  }

  String hardTailhardTailWithReboundPrompt() {
    return '$baseString Respond with json where the format is $hardTailWithRebound.';
  }
}
