# LoL App Constitution

## Core Principles

### I. Organisation par fonctionnalité
Le code vit dans `lib/<fonctionnalité>/` (`champions`, `items`, `quiz`, `map`, `regions`,
`matchups`, `runes`…). Chaque fonctionnalité regroupe sa page (`<nom>_page.dart`), ses
`models/`, ses `services/`, ses `constants/` et ses `widgets/`. Chaque widget réutilisable
est dans son propre dossier `widgets/<nom>/<nom>.dart`, et un fichier ne contient qu'un
widget public. Ce qui sert à plusieurs fonctionnalités va dans `lib/shared/`. Une
fonctionnalité MUST NOT importer les widgets internes d'une autre : elle passe par
`shared/` ou par un modèle.

### II. Données Riot via Data Dragon, erreurs toujours affichables
Tout appel réseau vers Riot passe par `DataDragonService` (timeout, version du jeu mise en
cache). Toute panne MUST ressortir en `DataDragonException` portant un message rédigé pour
l'utilisateur ; l'écran l'affiche avec `userMessageFor` et `ErrorRetryView`, jamais un
indicateur de chargement sans issue. Un échec MUST NOT être mis en cache : « Réessayer »
doit pouvoir retenter. Aucune clé API Riot n'est embarquée dans l'application.

### III. Images uniquement via RemoteImage
Toute image réseau passe par `RemoteImage` : cache disque hors web, repli sur
`Image.network` sur le web, fond de remplacement pendant le chargement, visuel discret en
cas de lien mort. Il est interdit d'appeler `Image.network` ou `CachedNetworkImage`
directement. La source est choisie selon la taille d'affichage : une icône de 120 px MUST
NOT être étirée dans une grande carte (utiliser `portraitUrl` ou le splash).

### IV. Thème centralisé
Couleurs, polices et styles viennent de `lib/theme/` (`AppColors`, `AppFonts`,
`AppTheme`). Les valeurs `Color(...)`, familles de polices et tailles de texte récurrentes
ne sont jamais écrites en dur dans un widget. Les polices (InstrumentSans, Spectral,
JetBrainsMono) sont embarquées dans `assets/fonts/` avec leur licence. Les couleurs
constantes restent `const`.

### V. État simple et local
L'état d'un écran utilise `StatefulWidget` et `setState`. L'état partagé entre écrans
(favoris, score du quiz) est un `ValueNotifier` exposé par un service, relu avant le
premier rendu quand l'affichage en dépend, et persisté avec `shared_preferences`. Un
paquet de gestion d'état (Provider, Riverpod, Bloc…) MUST NOT être ajouté sans justifier
dans le plan pourquoi `setState` et `ValueNotifier` ne suffisent plus. Les ressources
(contrôleurs, abonnements) sont libérées dans `dispose`.

### VI. Tests de la logique et des widgets clés (NON-NEGOTIABLE)
`test/` reflète l'arborescence de `lib/`. Toute logique métier (services, générateurs,
calculs, conversions de données) et tout widget qui porte une règle d'affichage reçoit un
test avec des données de test construites sur place ; aucun test n'appelle le réseau.
Une fonctionnalité n'est terminée que si `flutter analyze` ne remonte rien et que
`flutter test` passe.

### VII. Lisibilité, commentaires utiles, interface en français
Le texte affiché est en français et tutoie l'utilisateur (« Vérifie ta connexion »).
Les noms d'identifiants sont explicites, en anglais. Un commentaire explique le pourquoi
(une contrainte, un bug évité, un choix non évident), jamais ce que le code dit déjà. Les
valeurs numériques ou textuelles dont le sens n'est pas évident sont nommées. Les widgets
sont `const` partout où c'est possible.

## Contraintes techniques

- Plateformes : Flutter (SDK `^3.13`), exécuté sur mobile et sur le web. Tout code
  dépendant de la plateforme est isolé derrière `kIsWeb` ou une abstraction.
- Dépendances : `http`, `shared_preferences`, `cached_network_image`. Toute nouvelle
  dépendance est justifiée dans le plan de la fonctionnalité.
- Données statiques volumineuses (matchups, régions) sont générées par les scripts de
  `tool/` et embarquées sous `assets/data/` ; l'application ne recalcule jamais ces
  données au lancement. Tout asset est déclaré dans `pubspec.yaml`.
- Lints : `flutter_lints` ; le code généré et les dossiers de plateforme sont exclus de
  l'analyse.

## Workflow de développement

- Une fonctionnalité suit le cycle spec-kit : spécification, plan, tâches, implémentation.
- Le plan vérifie chaque principe ci-dessus ; un écart est écrit et justifié dans le plan.
- Les commits sont courts, en français, à l'infinitif ou au présent, et ne mélangent pas
  plusieurs sujets.
- Une vérification dans l'application (web ou appareil) accompagne tout changement visible.

## Governance

Cette constitution prime sur les autres pratiques du dépôt. Un amendement s'écrit dans ce
fichier, avec la raison du changement, et incrémente la version : MAJOR pour la
suppression ou la redéfinition d'un principe, MINOR pour un principe ou une section
ajoutés, PATCH pour une clarification. Chaque plan et chaque revue contrôlent la
conformité aux principes I à VII ; toute complexité ajoutée doit être justifiée.

**Version**: 1.0.0 | **Ratified**: 2026-10-05 | **Last Amended**: 2026-10-05
