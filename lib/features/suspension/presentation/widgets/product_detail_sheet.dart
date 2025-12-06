import 'package:flutter/material.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';

/// Bottom sheet showing detailed information about a suspension product with configuration
class ProductDetailSheet extends StatefulWidget {
  final SuspensionProduct product;
  final Function(SuspensionProduct product, Map<String, String> configuration) onSelect;

  const ProductDetailSheet({
    Key? key,
    required this.product,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  String? _selectedTravel;
  String? _selectedWheelSize;
  String? _selectedEyeToEye;
  String? _selectedStroke;

  @override
  void initState() {
    super.initState();
    // Set defaults to first available option
    if (widget.product.type == SuspensionType.fork) {
      _selectedTravel = widget.product.specs.travel?.firstOrNull;
      _selectedWheelSize = widget.product.specs.wheelSizes?.firstOrNull;
    } else {
      _selectedEyeToEye = widget.product.specs.eyeToEye;
      _selectedStroke = widget.product.specs.stroke;
    }
  }

  Map<String, String> _getConfiguration() {
    final config = <String, String>{};
    if (widget.product.type == SuspensionType.fork) {
      if (_selectedTravel != null) config['travel'] = _selectedTravel!;
      if (_selectedWheelSize != null) config['wheelSize'] = _selectedWheelSize!;
    } else {
      if (_selectedEyeToEye != null) config['eyeToEye'] = _selectedEyeToEye!;
      if (_selectedStroke != null) config['stroke'] = _selectedStroke!;
    }
    return config;
  }

  bool get _isConfigurationValid {
    if (widget.product.type == SuspensionType.fork) {
      return _selectedTravel != null && _selectedWheelSize != null;
    } else {
      return _selectedEyeToEye != null && _selectedStroke != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Product name
                        Text(
                          widget.product.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Category and type
                        Text(
                          widget.product.categoryAndType,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Configuration Section
                        _buildConfigurationSection(),

                        const SizedBox(height: 24),

                        // Specifications
                        _buildSection('Specifications', [
                          if (widget.product.specs.damperType != null)
                            _buildSpec('Damper', widget.product.specs.damperType!),
                          _buildSpec('Spring Type', widget.product.specs.springType.displayName),
                          if (widget.product.type == SuspensionType.fork) ...[
                            if (widget.product.specs.tubeType != null)
                              _buildSpec('Tube Diameter', widget.product.specs.tubeType!),
                            if (widget.product.specs.axleStandard != null)
                              _buildSpec('Axle Standard', widget.product.specs.axleStandard!),
                          ] else ...[
                            if (widget.product.specs.mountType != null)
                              _buildSpec('Mount Type', widget.product.specs.mountType!),
                          ],
                        ]),

                        // Features
                        if (widget.product.features.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSection(
                            'Features',
                            widget.product.features
                                .map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 20,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              f,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],

                        // Additional info
                        if (widget.product.msrp != null || widget.product.weight != null) ...[
                          const SizedBox(height: 24),
                          _buildSection('Additional Information', [
                            if (widget.product.msrp != null)
                              _buildSpec('MSRP', '\$${widget.product.msrp}'),
                            if (widget.product.weight != null)
                              _buildSpec('Weight', widget.product.weight!),
                          ]),
                        ],

                        // Baseline settings availability
                        if (widget.product.baselineSettings != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Baseline settings available for this product',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 100), // Space for button
                      ],
                    ),

                    // Floating select button
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isConfigurationValid
                              ? () => widget.onSelect(widget.product, _getConfiguration())
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Select This ${widget.product.type == SuspensionType.fork ? 'Fork' : 'Shock'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigurationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                'Configure Your Setup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.product.type == SuspensionType.fork) ...[
            // Travel dropdown
            if (widget.product.specs.travel != null && widget.product.specs.travel!.length > 1)
              _buildDropdown(
                label: 'Travel',
                value: _selectedTravel,
                items: widget.product.specs.travel!,
                onChanged: (value) {
                  setState(() {
                    _selectedTravel = value;
                  });
                },
              ),
            if (widget.product.specs.travel != null && widget.product.specs.travel!.length > 1)
              const SizedBox(height: 12),

            // Wheel size dropdown
            if (widget.product.specs.wheelSizes != null && widget.product.specs.wheelSizes!.length > 1)
              _buildDropdown(
                label: 'Wheel Size',
                value: _selectedWheelSize,
                items: widget.product.specs.wheelSizes!,
                onChanged: (value) {
                  setState(() {
                    _selectedWheelSize = value;
                  });
                },
              ),
          ] else ...[
            // For shocks, show eye-to-eye and stroke (usually fixed, but display them)
            if (widget.product.specs.eyeToEye != null)
              _buildInfoRow('Eye-to-Eye', widget.product.specs.eyeToEye!),
            if (widget.product.specs.stroke != null)
              _buildInfoRow('Stroke', widget.product.specs.stroke!),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSpec(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
