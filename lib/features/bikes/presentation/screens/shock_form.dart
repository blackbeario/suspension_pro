import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

class ShockForm extends ConsumerStatefulWidget {
  ShockForm({this.bikeId, this.shock, this.shockCallback});

  final String? bikeId;
  final Shock? shock;
  final Function(Map val)? shockCallback;

  @override
  ConsumerState<ShockForm> createState() => _ShockFormState();
}

class _ShockFormState extends ConsumerState<ShockForm> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _strokeController = TextEditingController();
  final _spacersController = TextEditingController();
  final _serialNumberController = TextEditingController();

  // Toggle for bikes with/without rear shock (hardtails)
  bool _isHardtail = false;

  @override
  void initState() {
    super.initState();
    var $shock = widget.shock;
    _yearController.text = $shock?.year ?? '';
    _brandController.text = $shock?.brand ?? '';
    _modelController.text = $shock?.model ?? '';
    _spacersController.text = $shock?.spacers ?? '';
    _strokeController.text = $shock?.stroke ?? '';
    _serialNumberController.text = $shock?.serialNumber ?? '';
  }

  @override
  void dispose() {
    _strokeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _spacersController.dispose();
    _yearController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<bool> _updateShock(bikeId, BuildContext context) async {
    Navigator.pop(context);

    // 1. Save shock to shocks box
    final Box box = await Hive.openBox('shocks');
    final Shock shock = Shock(
        bikeId: bikeId,
        year: _yearController.text,
        brand: _brandController.text,
        model: _modelController.text,
        spacers: _spacersController.text,
        stroke: _strokeController.text,
        serialNumber: _serialNumberController.text);
    await box.put(bikeId, shock);
    print('ShockForm: Shock saved to shocks box for bike $bikeId');

    // 2. Update the bike object to reference this shock
    final bikesBox = await Hive.openBox<Bike>('bikes');
    final bike = bikesBox.get(bikeId);
    if (bike != null) {
      final updatedBike = bike.copyWith(shock: shock);
      await bikesBox.put(bikeId, updatedBike);
      print('ShockForm: Updated bike object with shock reference');
    }

    // 3. Only sync to Firebase if user is Pro
    final isPro = ref.read(purchaseNotifierProvider).isPro;
    if (isPro) {
      final db = ref.read(databaseServiceProvider);
      await db.updateShock(bikeId, shock);
      print('ShockForm: Shock synced to Firebase for bike $bikeId');
    } else {
      print('ShockForm: User is not Pro, shock saved locally only');
    }

    // 4. Refresh BikesNotifier to trigger UI rebuild
    ref.read(bikesNotifierProvider.notifier).refreshFromHive();

    return Future.value(false);
  }

  Future<void> _deleteShock(String bikeId, BuildContext context) async {
    Navigator.pop(context);

    // Delete from Hive (source of truth)
    final Box shockBox = await Hive.openBox('shocks');
    await shockBox.delete(bikeId);
    print('ShockForm: Shock deleted from Hive for bike $bikeId');

    // Only sync to Firebase if user is Pro
    final isPro = ref.read(purchaseNotifierProvider).isPro;
    if (isPro) {
      final db = ref.read(databaseServiceProvider);
      await db.deleteField(bikeId, 'shock');
      print('ShockForm: Shock deletion synced to Firebase for bike $bikeId');
    } else {
      print('ShockForm: User is not Pro, shock deleted locally only');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 16),
                // Toggle switch for hardtail bikes (no rear suspension)
                SwitchListTile.adaptive(
                  title: Text(
                    'Hardtail?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _isHardtail
                        ? 'Toggle off for full squishy'
                        : 'Turn on if rocking a hardtail',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  value: _isHardtail,
                  onChanged: (bool value) {
                    setState(() => _isHardtail = value);
                  },
                ),
                SizedBox(height: 16),
                // Only show form fields if bike has a shock
                if (!_isHardtail) ...[
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter shock year';
                        return null;
                      },
                      decoration: _decoration('Shock Year'),
                      controller: _yearController,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      keyboardType: TextInputType.number),
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter shock brand';
                        return null;
                      },
                      decoration: _decoration('Shock Brand'),
                      controller: _brandController,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      keyboardType: TextInputType.text),
                  TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter shock model';
                        return null;
                      },
                      decoration: _decoration('Shock Model'),
                      controller: _modelController,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      keyboardType: TextInputType.text),
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: _decoration('Shock Stroke (ex: 210x52.5)'),
                      controller: _strokeController,
                      keyboardType: TextInputType.text),
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: _decoration('Shock Volume Spacers'),
                      controller: _spacersController,
                      keyboardType: TextInputType.number),
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: _decoration('Shock Serial Number'),
                      controller: _serialNumberController,
                      keyboardType: TextInputType.text),
                ], // End of conditional shock fields
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.only(left: 80, right: 80),
                  child: ElevatedButton(
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        // If no shock (hardtail mode)
                        if (_isHardtail) {
                          _yearController.clear();
                          _brandController.clear();
                          _modelController.clear();
                          _strokeController.clear();
                          _spacersController.clear();
                          _serialNumberController.clear();
                          // If editing existing bike and it had a shock, delete it
                          if (widget.bikeId != null &&
                              widget.bikeId!.isNotEmpty &&
                              widget.shock != null) {
                            await _deleteShock(widget.bikeId!, context);
                          } else {
                            // Just close the form for new bikes or bikes without shocks
                            Navigator.pop(context);
                          }
                          return;
                        }

                        // Validate shock form fields when shock is present
                        if (_formKey.currentState!.validate()) {
                          widget.bikeId != ''
                              ? _updateShock(widget.bikeId, context)
                              : widget.shockCallback!({
                                  'year': _yearController.text,
                                  'brand': _brandController.text,
                                  'model': _modelController.text,
                                  'spacers': _spacersController.text,
                                  'stroke': _strokeController.text,
                                  'serialNumber': _serialNumberController.text,
                                });
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      fillColor: Colors.white,
      filled: true,
      border: UnderlineInputBorder(borderRadius: BorderRadius.zero),
    );
  }
}
