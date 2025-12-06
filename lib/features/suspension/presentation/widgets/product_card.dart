import 'package:flutter/material.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';

/// Card widget displaying a suspension product in a list
class ProductCard extends StatelessWidget {
  final SuspensionProduct product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product icon/image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getBrandColor(product.brand).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  product.type == SuspensionType.fork
                      ? Icons.settings_input_component
                      : Icons.settings_input_hdmi,
                  size: 32,
                  color: _getBrandColor(product.brand),
                ),
              ),
              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Product details
                    Text(
                      _buildDetailsString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Damper type and price
                    if (product.specs.damperType != null || product.msrp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _buildSecondaryString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDetailsString() {
    final details = <String>[product.category.displayName];

    if (product.type == SuspensionType.fork) {
      if (product.specs.travel != null && product.specs.travel!.isNotEmpty) {
        details.add(product.specs.travel!.join(', '));
      }
      if (product.specs.wheelSizes != null && product.specs.wheelSizes!.isNotEmpty) {
        details.add(product.specs.wheelSizes!.join(', '));
      }
    } else {
      if (product.specs.eyeToEye != null) {
        details.add(product.specs.eyeToEye!);
      }
      if (product.specs.stroke != null) {
        details.add('${product.specs.stroke} stroke');
      }
    }

    return details.join(' • ');
  }

  String _buildSecondaryString() {
    final parts = <String>[];

    if (product.specs.damperType != null) {
      parts.add(product.specs.damperType!);
    }

    if (product.msrp != null) {
      parts.add('\$${product.msrp!.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}');
    }

    return parts.join(' • ');
  }

  Color _getBrandColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'fox':
        return Colors.orange;
      case 'rockshox':
        return Colors.red;
      case 'ohlins':
        return Colors.yellow.shade700;
      case 'manitou':
        return Colors.blue;
      case 'dvo':
        return Colors.purple;
      case 'cane creek':
        return Colors.green;
      case 'ext':
        return Colors.teal;
      case 'mrp':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
