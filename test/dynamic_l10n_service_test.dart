import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/services/dynamic_l10n_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DynamicL10nService Tests', () {
    test('initializes with default catalog and handles lookups', () async {
      SharedPreferences.setMockInitialValues({'m-locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final service = DynamicL10nService.instance;

      await service.initialize(prefs);
      expect(service.catalog.isNotEmpty, true);

      // Default English / system
      expect(service.isDownloaded('en'), true);
      expect(service.isDownloaded('system'), true);

      // Lookup returns null for English (so default strings pass through)
      expect(service.lookup('en', 'Settings'), null);

      // Lookup returns French translation when locale is French
      await service.loadLanguage('fr');
      final frLookup = service.lookup('fr', 'settings');
      expect(frLookup != null, true);
    });

    test('deleteLanguage removes language and reverts locale', () async {
      SharedPreferences.setMockInitialValues({'m-locale': 'fr'});
      final prefs = await SharedPreferences.getInstance();
      final service = DynamicL10nService.instance;

      await service.deleteLanguage('fr', prefs);
      expect(prefs.getString('m-locale'), 'en');
    });
  });
}
