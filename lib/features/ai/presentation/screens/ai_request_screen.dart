import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/ai/presentation/screens/ai_results.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/features/purchases/presentation/widgets/credits_banner.dart';
import 'package:ridemetrx/features/connectivity/presentation/widgets/connectivity_widget_wrapper.dart';

class AiRequestScreen extends ConsumerStatefulWidget {
  const AiRequestScreen({Key? key, this.selectedBike}) : super(key: key);

  final Bike? selectedBike;

  @override
  ConsumerState<AiRequestScreen> createState() => _AiRequestScreenState();
}

class _AiRequestScreenState extends ConsumerState<AiRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _riderWeightController = TextEditingController();
  final _trailConditionsController = TextEditingController();
  Bike? _selectedBike;
  String _selectedForkName = '';
  String _selectedShockName = '';

  @override
  void initState() {
    super.initState();
    _selectedBike = widget.selectedBike;
    _updateSelectedBikeNames();
  }

  @override
  void dispose() {
    _riderWeightController.dispose();
    _trailConditionsController.dispose();
    super.dispose();
  }

  void _updateSelectedBikeNames() {
    _selectedForkName = _selectedBike?.fork != null
        ? '${_selectedBike!.fork!.brand} ${_selectedBike!.fork!.model}'
        : '';
    _selectedShockName = _selectedBike?.shock != null
        ? '${_selectedBike!.shock!.brand} ${_selectedBike!.shock!.model}'
        : '';
  }

  List<Widget> _bikesList(List<Bike> bikes) {
    return bikes
        .map((bike) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(bike.id),
            ))
        .toList();
  }

  void _resetForm() {
    setState(() {
      _selectedBike = null;
      _selectedForkName = '';
      _selectedShockName = '';
      _riderWeightController.clear();
      _trailConditionsController.clear();
    });
  }

  Widget _getBikes(List<Bike> bikes, BuildContext context) {
    return ElevatedButton(
      child: const Text('Select Bike'),
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
                  _updateSelectedBikeNames();
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
    final bikesAsync = ref.watch(bikesStreamProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Suspension Suggestions')),
      body: ConnectivityWidgetWrapper(
        alignment: Alignment.center,
        stacked: false,
        offlineWidget: const Center(
          child: Text('You cannot use AI suggestions while offline'),
        ),
        child: ListView(
          children: [
            const CreditsBanner(),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Generate AI suspension suggestions by selecting a bike, entering trail conditions and rider weight.',
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Text(
                        'Include type of trail, (ex: downhill, flow, jump line) and also conditions (ex: steep, wet, loose, etc.)',
                      ),
                    ),

                    // Select Bike button
                    if (_selectedBike == null)
                      bikesAsync.when(
                        data: (bikes) {
                          if (bikes.isEmpty) {
                            return const Text('No bikes available. Add a bike first.');
                          }
                          return _getBikes(bikes, context);
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Cannot fetch list of user bikes'),
                      ),

                    // Selected bike info
                    if (_selectedBike != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(_selectedBike!.id),
                                  if (_selectedForkName.isNotEmpty)
                                    Text('Fork: $_selectedForkName'),
                                  if (_selectedShockName.isNotEmpty)
                                    Text('Shock: $_selectedShockName'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Rider weight
                    if (_selectedBike != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter rider weight';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            icon: _riderWeightController.text.isEmpty
                                ? const Icon(Icons.question_mark_rounded)
                                : const Icon(Icons.check_circle),
                            iconColor: _riderWeightController.text.isEmpty
                                ? null
                                : Colors.green,
                            hintText: 'rider weight',
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _riderWeightController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
                          ],
                        ),
                      ),

                    // Trail conditions
                    if (_riderWeightController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe trail conditions';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            icon: _trailConditionsController.text.isEmpty
                                ? const Icon(Icons.question_mark_rounded)
                                : const Icon(Icons.check_circle),
                            iconColor: _trailConditionsController.text.isEmpty
                                ? null
                                : Colors.green,
                            hintText: 'trail conditions',
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _trailConditionsController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                    // Submit button
                    if (_riderWeightController.text.isNotEmpty &&
                        _trailConditionsController.text.isNotEmpty)
                      ElevatedButton(
                        child: const Text(
                          'Get Suggestions',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Deduct AI credit using Riverpod
                            ref.read(purchaseNotifierProvider.notifier).removeCredit();

                            showCupertinoModalPopup(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => AiResultsDialog(
                                weight: _riderWeightController.text,
                                year: _selectedBike!.yearModel.toString(),
                                bikeId: _selectedBike!.id,
                                forkName: _selectedForkName,
                                shockName: _selectedShockName,
                                trailConditions: _trailConditionsController.text,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
