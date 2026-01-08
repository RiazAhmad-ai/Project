import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  StreamSubscription? _settingsSubscription;
  
  SettingsProvider() {
    _settingsSubscription = _settingsBox.watch().listen((_) => notifyListeners());
  }

  final Box _settingsBox = Hive.box('settingsBox');
  
  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  String get shopName => _settingsBox.get('shopName', defaultValue: "RsellX - [Your Business Name]");
  String get ownerName => _settingsBox.get('ownerName', defaultValue: "[Enter Owner Name]");
  String get phone => _settingsBox.get('phone', defaultValue: "[Enter Phone Number]");
  String get address => _settingsBox.get('address', defaultValue: "[Tap Settings to add your Address]");
  String? get logoPath => _settingsBox.get('logoPath');
  String get adminPasscode => _settingsBox.get('adminPasscode', defaultValue: "1234");

  Future<void> updateProfile(String name, String shop, String phone, String address, {String? logo}) async {
    await _settingsBox.put('ownerName', name);
    await _settingsBox.put('shopName', shop);
    await _settingsBox.put('phone', phone);
    await _settingsBox.put('address', address);
    if (logo != null) await _settingsBox.put('logoPath', logo);
    notifyListeners();
  }

  Future<void> updatePasscode(String newPasscode) async {
    await _settingsBox.put('adminPasscode', newPasscode);
    notifyListeners();
  }
}
