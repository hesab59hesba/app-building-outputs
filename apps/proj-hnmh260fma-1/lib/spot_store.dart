import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'parking_spot.dart';

enum SpotStatus { idle, locating, saved }

class SpotStore extends ChangeNotifier {
  ParkingSpot? _spot;
  SpotStatus _status = SpotStatus.idle;
  String? _error;
  double? _distanceMeters;
  bool _measuring = false;
  Timer? _ticker;

  ParkingSpot? get spot => _spot;
  SpotStatus get status => _status;
  String? get error => _error;
  double? get distanceMeters => _distanceMeters;
  bool get isMeasuring => _measuring;

  Future<void> saveCurrentLocation() async {
    if (_status == SpotStatus.locating) return;
    _error = null;
    _status = SpotStatus.locating;
    notifyListeners();
    try {
      final position = await _acquireFix();
      _spot = ParkingSpot(
        latitude: position.latitude,
        longitude: position.longitude,
        savedAt: DateTime.now(),
      );
      _distanceMeters = 0;
      _status = SpotStatus.saved;
      _startTicker();
      notifyListeners();
    } on LocationServiceDisabledException {
      _fail('Location services are disabled. Turn them on and try again.');
    } on PermissionDeniedException {
      _fail('Location permission was denied. Grant it and try again.');
    } on TimeoutException {
      _fail('Could not get a GPS fix in time. Try again under open sky.');
    } catch (_) {
      _fail('Could not determine your location. Please try again.');
    }
  }

  Future<void> refreshDistance() async {
    final spot = _spot;
    if (spot == null || _measuring) return;
    _error = null;
    _measuring = true;
    notifyListeners();
    try {
      final position = await _acquireFix();
      _distanceMeters = Geolocator.distanceBetween(
        spot.latitude,
        spot.longitude,
        position.latitude,
        position.longitude,
      );
    } on LocationServiceDisabledException {
      _fail('Location services are disabled. Turn them on and try again.');
    } on PermissionDeniedException {
      _fail('Location permission was denied. Grant it and try again.');
    } on TimeoutException {
      _fail('Could not get a GPS fix in time. Try again under open sky.');
    } catch (_) {
      _fail('Could not determine your location. Please try again.');
    } finally {
      _measuring = false;
      notifyListeners();
    }
  }

  void updateNote(String note) {
    final spot = _spot;
    if (spot == null) return;
    final trimmed = note.trim();
    _spot = spot.copyWith(note: trimmed.isEmpty ? null : trimmed);
    notifyListeners();
  }

  Future<bool> openDirections() async {
    final spot = _spot;
    if (spot == null) return false;
    final lat = spot.latitude.toStringAsFixed(6);
    final lng = spot.longitude.toStringAsFixed(6);
    final Uri uri;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=w');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
      );
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  void release() {
    _ticker?.cancel();
    _ticker = null;
    _spot = null;
    _distanceMeters = null;
    _error = null;
    _status = SpotStatus.idle;
    notifyListeners();
  }

  Future<Position> _acquireFix() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw LocationServiceDisabledException();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException('location permission denied forever');
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw PermissionDeniedException('location permission denied');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  void _fail(String message) {
    _error = message;
    _status = _spot == null ? SpotStatus.idle : SpotStatus.saved;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_spot == null) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
