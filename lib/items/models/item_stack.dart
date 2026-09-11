import 'item.dart';

/// Un objet et le nombre d'exemplaires qu'une recette en demande.
///
/// L'Armure roncière se compose de deux Armures d'étoffe : la recette de Riot
/// répète l'identifiant, la quantité n'est donc pas un champ à part.
class ItemStack {
  final Item item;
  final int count;

  const ItemStack({required this.item, required this.count});

  bool get isSingle => count == 1;
}
