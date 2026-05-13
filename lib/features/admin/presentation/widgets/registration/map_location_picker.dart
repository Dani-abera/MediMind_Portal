import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationPicked;

  const MapLocationPicker({
    super.key,
    this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? _picked;
  // Default center: Addis Ababa, Ethiopia
  final _defaultCenter = const LatLng(9.0192, 38.7525);

  @override
  void initState() {
    super.initState();
    _picked = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pin Location on Map',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(tap to place marker)',
              style: AppTypography.caption.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _picked ?? _defaultCenter,
                initialZoom: _picked != null ? 14.0 : 11.0,
                onTap: (tapPosition, point) {
                  setState(() => _picked = point);
                  widget.onLocationPicked(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.medimind.portal',
                ),
                if (_picked != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _picked!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.danger,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (_picked != null)
          Row(
            children: [
              const Icon(Icons.my_location,
                  size: 14, color: AppColors.neutral500),
              const SizedBox(width: 4),
              Text(
                'Lat: ${_picked!.latitude.toStringAsFixed(6)}, '
                'Lng: ${_picked!.longitude.toStringAsFixed(6)}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _picked = null);
                },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Clear',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.danger)),
              ),
            ],
          )
        else
          Text(
            'No location selected — tap the map to set one',
            style:
                AppTypography.caption.copyWith(color: AppColors.neutral400),
          ),
      ],
    );
  }
}
