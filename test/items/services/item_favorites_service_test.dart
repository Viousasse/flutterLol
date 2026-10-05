import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/items/services/item_favorites_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('garde les objets favoris à part des champions favoris', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_items': ['3031'],
      'favorite_champions': ['Ahri'],
    });

    await ItemFavoritesService.ensureLoaded();
    expect(ItemFavoritesService.isFavorite('3031'), isTrue);
    expect(ItemFavoritesService.isFavorite('Ahri'), isFalse);

    await ItemFavoritesService.toggleFavorite('3089');
    expect(ItemFavoritesService.favorites.value, {'3031', '3089'});

    await ItemFavoritesService.toggleFavorite('3031');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorite_items'), ['3089']);
    expect(prefs.getStringList('favorite_champions'), ['Ahri']);
  });
}
