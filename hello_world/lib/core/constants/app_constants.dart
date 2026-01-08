/// Application-wide constants for the RsellX inventory management app
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // === PAGINATION ===
  static const int defaultPageSize = 20;
  static const int loadMoreThreshold = 200; // pixels from bottom to trigger load more

  // === STOCK THRESHOLDS ===
  static const int defaultLowStockThreshold = 5;
  static const int criticalStockLevel = 2;

  // === ANIMATION DURATIONS ===
  static const int splashAnimationDuration = 1500; // milliseconds
  static const int splashDelayDuration = 200; // milliseconds
  static const int fadeTransitionDuration = 800; // milliseconds
  static const int staggeredAnimationDuration = 375; // milliseconds

  // === UI CONSTANTS ===
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 0.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 12.0;

  // === DEFAULT VALUES ===
  static const String defaultShopName = "RsellX - [Your Business Name]";
  static const String defaultOwnerName = "[Enter Owner Name]";
  static const String defaultPhone = "[Enter Phone Number]";
  static const String defaultAddress = "[Tap Settings to add your Address]";
  static const String defaultAdminPasscode = "1234";
  static const String defaultCategory = "General";
  static const String defaultSize = "N/A";
  static const String defaultBarcode = "N/A";

  // === ANALYTICS ===
  static const int topProductsLimit = 5;
  static const List<String> analyticsFilters = ["Weekly", "Monthly", "Annual"];
  
  // === CHART LABELS ===
  static const List<String> weekDayLabels = ["M", "T", "W", "T", "F", "S", "S"];
  static const List<String> weekLabels = ["W1", "W2", "W3", "W4"];
  static const List<String> monthLabels = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];

  // === DATABASE ===
  static const String inventoryBoxName = 'inventoryBox';
  static const String historyBoxName = 'historyBox';
  static const String cartBoxName = 'cartBox';
  static const String expensesBoxName = 'expensesBox';
  static const String creditsBoxName = 'creditsBox';
  static const String damageBoxName = 'damageBox';
  static const String settingsBoxName = 'settingsBox';

  // === SCROLL PHYSICS ===
  static const double scrollVelocity = 50.0;

  // === BARCODE ===
  static const String barcodePrefix = "RSELLX";
  
  // === FILE FORMATS ===
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocFormats = ['pdf', 'xlsx', 'xls'];

  // === PERFORMANCE ===
  static const int maxCachedItems = 1000;
  static const int debounceMilliseconds = 300;

  // === ERROR MESSAGES ===
  static const String itemNotFoundError = "❌ Item not found with code";
  static const String deletionError = "Failed to delete";
  static const String updateError = "Failed to update";
  static const String networkError = "Network connection error";
  
  // === SUCCESS MESSAGES ===
  static const String itemDeletedSuccess = "Item Deleted";
  static const String itemAddedSuccess = "Item Added";
  static const String itemUpdatedSuccess = "Item Updated";
  static const String backupExportedSuccess = "Backup exported successfully";
  static const String backupImportedSuccess = "Backup imported successfully";
}
