import 'package:flutter/foundation.dart';

class LocationPermissionViewModel extends ChangeNotifier {
  bool _isRequesting = false;
  bool _granted = false;
  String? _error;

  bool get isRequesting => _isRequesting;
  bool get granted => _granted;
  String? get error => _error;

  Future<void> requestPermission() async {
    _isRequesting = true;
    _error = null;
    notifyListeners();

    // bool serviceEnabled = await _location.serviceEnabled();
    // if (!serviceEnabled) {
    //   serviceEnabled = await _location.requestService();
    //   if (!serviceEnabled) {
    //     _error = 'Location services are disabled.';
    //     _isRequesting = false;
    //     notifyListeners();
    //     return;
    //   }
    // }

    // PermissionStatus permissionGranted = await _location.hasPermission();
    // if (permissionGranted == PermissionStatus.denied) {
    //   permissionGranted = await _location.requestPermission();
    //   if (permissionGranted != PermissionStatus.granted) {
    //     _error = 'Permission denied.';
    //     _isRequesting = false;
    //     notifyListeners();
    //     return;
    //   }
    // }

    _granted = true;
    _isRequesting = false;
    notifyListeners();
  }
}

