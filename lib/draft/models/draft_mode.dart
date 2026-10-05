import 'draft_report.dart';

/// Contre qui se joue la draft.
enum DraftMode {
  /// Le joueur (camp bleu) affronte le site, qui joue le camp rouge.
  vsSite,

  /// Deux joueurs se passent l'appareil : l'un joue le bleu, l'autre le rouge.
  vsFriend;

  /// Les joueurs d'un duel, ou `null` contre le site (le bilan s'adresse alors
  /// directement au joueur).
  DraftPlayers? get players {
    return this == vsFriend ? friendPlayers : null;
  }
}

const friendPlayers = DraftPlayers(blue: 'Joueur 1', red: 'Joueur 2');
