import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike_product.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/bike_picker_screen.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/bike_form_view_model.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/hardtail_switch.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';
import 'package:ridemetrx/features/suspension/presentation/screens/suspension_picker_screen.dart';

/// Wizard-style screen for adding a new bike with 3 steps:
/// 1. Select Bike (from database or manual entry)
/// 2. Select Fork (from database or manual entry)
/// 3. Select Shock (from database or manual entry, or skip for hardtail)
class BikeWizardScreen extends ConsumerStatefulWidget {
  const BikeWizardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BikeWizardScreen> createState() => _BikeWizardScreenState();
}

class _BikeWizardScreenState extends ConsumerState<BikeWizardScreen> {
  int _currentStep = 0;

  // Step 1: Bike selection
  BikeProduct? _selectedBike;
  final TextEditingController _bikeBrandController = TextEditingController();
  final TextEditingController _bikeModelController = TextEditingController();
  final TextEditingController _bikeYearController = TextEditingController();
  bool _useManualBikeEntry = false;

  // Step 2: Fork selection
  SuspensionProduct? _selectedFork;
  bool _useManualForkEntry = false;

  // Step 3: Shock selection
  SuspensionProduct? _selectedShock;
  bool _useManualShockEntry = false;
  bool _isHardtail = false;

  @override
  void initState() {
    super.initState();
    // Listen to text field changes to update button state
    _bikeBrandController.addListener(() => setState(() {}));
    _bikeModelController.addListener(() => setState(() {}));
    _bikeYearController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bikeBrandController.dispose();
    _bikeModelController.dispose();
    _bikeYearController.dispose();
    super.dispose();
  }

  bool _isStep1Valid() {
    if (_selectedBike != null) return true;
    if (_useManualBikeEntry) {
      return _bikeBrandController.text.isNotEmpty &&
          _bikeModelController.text.isNotEmpty &&
          _bikeYearController.text.isNotEmpty;
    }
    return false;
  }

  bool _isStep2Valid() {
    // Always valid - we create a placeholder fork if not selected
    return true;
  }

  bool _isStep3Valid() {
    return _selectedShock != null || _useManualShockEntry || _isHardtail;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _saveBike();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _saveBike() async {
    // Build bike name from selected product or manual entry
    final String bikeName;
    final int yearModel;

    if (_selectedBike != null) {
      bikeName = '${_selectedBike!.brand} ${_selectedBike!.model}';
      yearModel = int.parse(_selectedBike!.year);
    } else {
      bikeName = '${_bikeBrandController.text} ${_bikeModelController.text}';
      yearModel = int.parse(_bikeYearController.text);
    }

    print('BikeWizard: Saving bike: $bikeName, year: $yearModel');
    print('BikeWizard: Selected fork: $_selectedFork, manual fork: $_useManualForkEntry');
    print('BikeWizard: Selected shock: $_selectedShock, manual shock: $_useManualShockEntry, hardtail: $_isHardtail');

    // Build Fork object - ALWAYS create one since most bikes have forks
    Fork fork;
    if (_selectedFork != null) {
      fork = Fork(
        bikeId: bikeName,
        brand: _selectedFork!.brand,
        model: _selectedFork!.model,
        year: _selectedFork!.year,
        travel: _selectedFork!.specs.travel?.first,
        wheelsize: _selectedFork!.specs.wheelSizes?.first,
        damper: _selectedFork!.specs.damperType,
        // offset: Not available in SuspensionSpecs, can be added manually later
      );
    } else {
      // Manual entry or not selected - create placeholder
      fork = Fork(
        bikeId: bikeName,
        brand: 'Unknown',
        model: 'Unknown',
        year: yearModel.toString(),
      );
    }

    // Build Shock object
    Shock? shock;
    if (!_isHardtail) {
      if (_selectedShock != null) {
        shock = Shock(
          bikeId: bikeName,
          brand: _selectedShock!.brand,
          model: _selectedShock!.model,
          year: _selectedShock!.year,
          stroke: _selectedShock!.specs.stroke,
        );
      } else if (_useManualShockEntry) {
        // Shock will be added via manual form later
        // Create placeholder for now
        shock = Shock(
          bikeId: bikeName,
          brand: 'Unknown',
          model: 'Unknown',
          year: yearModel.toString(),
        );
      }
    }

    // Save bike using the existing view model
    final viewModel = ref.read(bikeFormViewModelProvider.notifier);
    final success = await viewModel.saveBike(
      bikeName: bikeName,
      yearModel: yearModel,
      fork: fork,
      shock: shock,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Bike saved and synced to cloud!'
                : 'Bike saved locally!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Bike'),
                _buildStepConnector(0),
                _buildStepIndicator(1, 'Fork'),
                _buildStepConnector(1),
                _buildStepIndicator(2, 'Shock'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Step content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1BikeSelection(),
                _buildStep2ForkSelection(),
                _buildStep3ShockSelection(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_currentStep == 2 ? 'Save' : 'Next'),
                        if (_currentStep < 2) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _isStep1Valid();
      case 1:
        return _isStep2Valid();
      case 2:
        return _isStep3Valid();
      default:
        return false;
    }
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted
          ? Theme.of(context).primaryColor
          : Colors.grey.shade300,
    );
  }

  Widget _buildStep1BikeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Your Bike',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your bike from our database or enter manually',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          if (!_useManualBikeEntry && _selectedBike == null) ...[
            // Option 1: Choose from database
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BikePickerScreen(
                      onSelect: (bike) {
                        setState(() {
                          _selectedBike = bike;
                          _useManualBikeEntry = false;
                        });
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Choose from Database'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Manual entry
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _useManualBikeEntry = true;
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Enter Manually'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],

          // Show selected bike
          if (_selectedBike != null) ...[
            _buildSelectedBikeCard(),
          ],

          // Show manual entry form
          if (_useManualBikeEntry) ...[
            _buildManualBikeForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedBikeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Bike',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedBike!.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedBike!.category.displayName}${_selectedBike!.wheelSize != null ? ' • ${_selectedBike!.wheelSize}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedBike = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualBikeForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manual Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _useManualBikeEntry = false;
                      _bikeBrandController.clear();
                      _bikeModelController.clear();
                      _bikeYearController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bikeBrandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                hintText: 'e.g., Santa Cruz',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bikeModelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., Nomad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bikeYearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g., 2024',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2ForkSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Fork',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your fork from our database or enter manually',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          if (!_useManualForkEntry && _selectedFork == null) ...[
            // Option 1: Choose from database
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuspensionPickerScreen(
                      type: SuspensionType.fork,
                      onSelect: (fork) {
                        setState(() {
                          _selectedFork = fork;
                          _useManualForkEntry = false;
                        });
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Choose from Database'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Manual entry
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _useManualForkEntry = true;
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Enter Manually'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],

          // Show selected fork
          if (_selectedFork != null) ...[
            _buildSelectedSuspensionCard(_selectedFork!, 'Fork', () {
              setState(() {
                _selectedFork = null;
              });
            }),
          ],

          // Show manual entry placeholder
          if (_useManualForkEntry) ...[
            _buildManualSuspensionPlaceholder('Fork', () {
              setState(() {
                _useManualForkEntry = false;
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3ShockSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Shock',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your shock or skip if you have a hardtail',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Hardtail switch
          HardtailSwitch(
            value: _isHardtail,
            onChanged: (value) {
              setState(() {
                _isHardtail = value;
                if (_isHardtail) {
                  _selectedShock = null;
                  _useManualShockEntry = false;
                }
              });
            },
          ),

          if (!_isHardtail) ...[
            const SizedBox(height: 16),

            if (!_useManualShockEntry && _selectedShock == null) ...[
              // Option 1: Choose from database
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuspensionPickerScreen(
                        type: SuspensionType.shock,
                        onSelect: (shock) {
                          setState(() {
                            _selectedShock = shock;
                            _useManualShockEntry = false;
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Choose from Database'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Manual entry
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _useManualShockEntry = true;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Enter Manually'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],

            // Show selected shock
            if (_selectedShock != null) ...[
              _buildSelectedSuspensionCard(_selectedShock!, 'Shock', () {
                setState(() {
                  _selectedShock = null;
                });
              }),
            ],

            // Show manual entry placeholder
            if (_useManualShockEntry) ...[
              _buildManualSuspensionPlaceholder('Shock', () {
                setState(() {
                  _useManualShockEntry = false;
                });
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedSuspensionCard(
    SuspensionProduct product,
    String type,
    VoidCallback onRemove,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected $type',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualSuspensionPlaceholder(String type, VoidCallback onRemove) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manual Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You\'ll be able to enter $type details after saving',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
