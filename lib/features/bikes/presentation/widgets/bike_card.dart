import 'package:flutter/material.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike_product.dart';

/// Card widget displaying a bike product in a list
class BikeCard extends StatelessWidget {
  final BikeProduct bike;
  final VoidCallback onTap;

  const BikeCard({
    Key? key,
    required this.bike,
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
              // Bike icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(bike.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pedal_bike,
                  size: 32,
                  color: _getCategoryColor(bike.category),
                ),
              ),
              const SizedBox(width: 16),

              // Bike info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bike name
                    Text(
                      '${bike.brand} ${bike.model}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Year and category
                    Text(
                      'Year: ${bike.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Category and wheel size
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _buildDetailsString(),
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
    final parts = <String>[bike.category.displayName];

    if (bike.wheelSize != null) {
      parts.add(bike.wheelSize!);
    }

    if (bike.msrp != null) {
      parts.add('\$${bike.msrp!.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}');
    }

    return parts.join(' • ');
  }

  Color _getCategoryColor(BikeCategory category) {
    switch (category) {
      case BikeCategory.xc:
        return Colors.green;
      case BikeCategory.trail:
        return Colors.blue;
      case BikeCategory.enduro:
        return Colors.orange;
      case BikeCategory.dh:
        return Colors.red;
    }
  }
}
