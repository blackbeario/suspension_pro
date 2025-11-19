import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suspension_pro/core/services/db_service.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/views/ai_results.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/features/purchases/presentation/widgets/credits_banner.dart';

class OpenAiRequest extends StatefulWidget {
  OpenAiRequest({Key? key, this.selectedBike}) : super(key: key);

  final Bike? selectedBike;

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

  @override
  void initState() {
    super.initState();
    _selectedBike = widget.selectedBike;
    _selectedForkName = _selectedBike?.fork != null
                      ? (_selectedBike!.fork!.brand + ' ' + _selectedBike!.fork!.model)
                      : '';
    _selectedShockName = _selectedBike?.shock != null
                      ? (_selectedBike!.shock!.brand + ' ' + _selectedBike!.shock!.model)
                      : '';
  }

  @override
  void dispose() {
    _riderWeightController.dispose();
    _trailCondtionsController.dispose();
    super.dispose();
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
    return ElevatedButton(
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Suspension Suggestions')),
      body: ConnectivityWidgetWrapper(
        alignment: Alignment.center,
        stacked: false,
        offlineWidget: Center(child: Text('You cannot buy credits while offline')),
        child: ListView(
          children: [
            CreditsBanner(),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        'Generate AI suspension suggestions by selecting a bike, entering trail conditions and rider weight.'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Text(
                          'Include type of trail, (ex: downhill, flow, jump line) and also conditions (ex: steep, wet, loose, etc.)'),
                    ),

                    // Select Bike button
                    if (_selectedBike == null)
                      StreamBuilder<List<Bike>>(
                        stream: db.streamBikes(),
                        builder: (context, snapshot) {
                          List<Bike>? bikes = snapshot.data;
                          if (!snapshot.hasData || snapshot.hasError) {
                            return Text('Cannot fetch list of user bikes');
                          }
                          return _getBikes(bikes!, context);
                        },
                      ),

                    if (_selectedBike != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(_selectedBike!.id),
                                  if (_selectedForkName.isNotEmpty) Text('Fork: $_selectedForkName'),
                                  if (_selectedShockName.isNotEmpty) Text('Shock: $_selectedShockName'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // rider weight
                    if (_selectedBike != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          validator: (_riderWeightController) {
                            if (_riderWeightController == null || _riderWeightController.isEmpty)
                              return 'Please enter rider weight';
                            return null;
                          },
                          decoration: InputDecoration(
                            icon: _riderWeightController.text.isEmpty
                                ? Icon(Icons.question_mark_rounded)
                                : Icon(Icons.check_circle),
                            iconColor: _riderWeightController.text.isEmpty ? null : Colors.green,
                            hintText: 'rider weight',
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _riderWeightController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true),
                          inputFormatters: [FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)],
                        ),
                      ),

                    // trail conditions
                    if (_riderWeightController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          validator: (_trailCondtionsController) {
                            if (_trailCondtionsController == null || _trailCondtionsController.isEmpty)
                              return 'Please describe trail conditions';
                            return null;
                          },
                          decoration: InputDecoration(
                            icon: _trailCondtionsController.text.isEmpty
                                ? Icon(Icons.question_mark_rounded)
                                : Icon(Icons.check_circle),
                            iconColor: _trailCondtionsController.text.isEmpty ? null : Colors.green,
                            hintText: 'trail conditions',
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _trailCondtionsController,
                          keyboardType: TextInputType.text,
                        ),
                      ),

                    // submit widget
                    if (_riderWeightController.text.isNotEmpty && _trailCondtionsController.text.isNotEmpty)
                      ElevatedButton(
                          child: Text('Get Suggestions', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              InAppBloc().removeCredit();
                              showCupertinoModalPopup(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => AiResultsDialog(
                                  weight: _riderWeightController.text,
                                  year: _selectedBike!.yearModel.toString(),
                                  bikeId: _selectedBike!.id,
                                  forkName: _selectedForkName,
                                  shockName: _selectedShockName,
                                  trailConditions: _trailCondtionsController.text,
                                ),
                              );
                            }
                          }),
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
