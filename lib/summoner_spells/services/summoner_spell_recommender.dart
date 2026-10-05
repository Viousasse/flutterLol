/// Les deux sorts conseillés pour un champion, avec la raison du choix.
class SummonerSpellPlan {
  final List<String> spellIds;
  final String reason;

  const SummonerSpellPlan({required this.spellIds, required this.reason});
}

/// Choisit les sorts d'invocateur d'après la voie où le champion se joue le plus
/// et son profil.
///
/// Data Dragon ne publie aucun sort conseillé : comme pour les runes, ces choix
/// sont rédigés à la main, par voie et par profil, d'après les usages les plus
/// répandus.
class SummonerSpellRecommender {
  static const flash = 'SummonerFlash';
  static const smite = 'SummonerSmite';
  static const ignite = 'SummonerDot';
  static const teleport = 'SummonerTeleport';
  static const heal = 'SummonerHeal';
  static const exhaust = 'SummonerExhaust';

  /// [lane] est la voie la plus jouée dans les parties analysées (`TOP`,
  /// `JUNGLE`, `MIDDLE`, `BOTTOM`, `UTILITY`), ou `null` si on ne la connaît
  /// pas : le profil du champion décide alors seul.
  static SummonerSpellPlan recommend({
    required List<String> tags,
    String? lane,
  }) {
    final profile = tags.isEmpty ? 'Fighter' : tags.first;

    switch (lane) {
      case 'JUNGLE':
        return const SummonerSpellPlan(
          spellIds: [smite, flash],
          reason:
              'En jungle, Châtiment sert à sécuriser les monstres et les '
              'objectifs.',
        );
      case 'BOTTOM':
        return const SummonerSpellPlan(
          spellIds: [flash, heal],
          reason: 'En bas de la carte, Soins aide à survivre aux échanges.',
        );
      case 'UTILITY':
        return profile == 'Support'
            ? const SummonerSpellPlan(
                spellIds: [flash, exhaust],
                reason: 'Épuisement protège votre allié contre un assassin.',
              )
            : const SummonerSpellPlan(
                spellIds: [flash, ignite],
                reason: 'Embrasement aide à tuer une cible fragile.',
              );
      case 'TOP':
        return _isFrontliner(profile)
            ? const SummonerSpellPlan(
                spellIds: [flash, teleport],
                reason:
                    'En haut, Téléportation permet de rejoindre les combats '
                    'et de revenir en voie.',
              )
            : const SummonerSpellPlan(
                spellIds: [flash, ignite],
                reason: 'Embrasement donne l’avantage en duel en haut.',
              );
      case 'MIDDLE':
        return _isFrontliner(profile)
            ? const SummonerSpellPlan(
                spellIds: [flash, teleport],
                reason: 'Téléportation aide à rejoindre les autres voies.',
              )
            : const SummonerSpellPlan(
                spellIds: [flash, ignite],
                reason: 'Embrasement aide à achever les cibles en milieu.',
              );
    }

    return _fromProfile(profile);
  }

  static bool _isFrontliner(String profile) {
    return profile == 'Tank' || profile == 'Fighter';
  }

  static SummonerSpellPlan _fromProfile(String profile) {
    switch (profile) {
      case 'Marksman':
        return const SummonerSpellPlan(
          spellIds: [flash, heal],
          reason: 'Un tireur choisit Soins pour survivre aux échanges.',
        );
      case 'Support':
        return const SummonerSpellPlan(
          spellIds: [flash, exhaust],
          reason: 'Épuisement protège votre équipe contre les menaces.',
        );
      case 'Tank':
      case 'Fighter':
        return const SummonerSpellPlan(
          spellIds: [flash, teleport],
          reason: 'Téléportation est le choix courant des combattants.',
        );
      default:
        return const SummonerSpellPlan(
          spellIds: [flash, ignite],
          reason: 'Embrasement aide à tuer ou à gagner un duel.',
        );
    }
  }
}
