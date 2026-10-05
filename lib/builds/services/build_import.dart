import '../models/build.dart';
import 'build_share_code.dart';
import 'build_store.dart';

/// Lit une build dans [text] (un code, ou un message qui en contient un) et
/// l'enregistre. Renvoie `null`, sans rien enregistrer, si le texte n'en
/// contient pas de valide.
Future<Build?> importBuildFromText(String text) async {
  final build = BuildShareCode.decode(text);
  if (build == null) return null;

  await BuildStore.save(build);

  return build;
}
