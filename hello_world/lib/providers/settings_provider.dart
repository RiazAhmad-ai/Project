import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _settingsBox.watch().listen((_) => notifyListeners());
  }

  final Box _settingsBox = Hive.box('settingsBox');

  String get shopName => _settingsBox.get('shopName', defaultValue: "RsellX");
  String get ownerName => _settingsBox.get('ownerName', defaultValue: "Riaz Ahmad");
  String get phone => _settingsBox.get('phone', defaultValue: "+92 3195910091");
  String get address => _settingsBox.get('address', defaultValue: "Jehangira Underpass Shop#21");
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
