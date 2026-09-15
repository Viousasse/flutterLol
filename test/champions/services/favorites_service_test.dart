import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/services/favorites_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('relit les favoris enregistres et previent a chaque changement', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_champions': ['Ahri'],
    });

    await FavoritesService.ensureLoaded();
    expect(FavoritesService.isFavorite('Ahri'), isTrue);

    var notifications = 0;
    FavoritesService.favorites.addListener(() => notifications++);

    await FavoritesService.toggleFavorite('Zed');
    expect(FavoritesService.favorites.value, {'Ahri', 'Zed'});

    await FavoritesService.toggleFavorite('Ahri');
    expect(FavoritesService.favorites.value, {'Zed'});

    // Deux bascules, deux notifications : c'est ce qui permet a la carte et a
    // la fiche d'un champion de rester d'accord sans se connaitre.
    expect(notifications, 2);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorite_champions'), ['Zed']);
  });
}
