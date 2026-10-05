# Implementation Plan: Données hors ligne

**Branch**: `002-donnees-hors-ligne` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-donnees-hors-ligne/spec.md`

## Summary

`DataDragonService.fetchJson` garde, quand on lui donne un `offlineKey`, le corps du dernier document JSON valide dans `shared_preferences` (`OfflineJsonCache`) et le resert quand le téléchargement échoue. Le durcissement ajoute un contrôle de forme (`isValid`), une borne par famille de clés (`offlineKeepLast`) utilisée pour les fiches de champions (`champion:<id>`, 12 copies), une panne d'origine remontée quand la copie est illisible, et une page de la carte qui sait réessayer.

## Technical Context

**Language/Version**: Dart 3 / Flutter (SDK `^3.13.3`)

**Primary Dependencies**: `http` (téléchargement, `MockClient` en test), `shared_preferences` (copies) ; aucune nouvelle dépendance

**Storage**: `shared_preferences`, clés `ddragon_offline_<nom>` (corps JSON) et `ddragon_recent_<famille>` (liste d'ancienneté)

**Testing**: `flutter_test` avec `MockClient` et `SharedPreferences.setMockInitialValues`

**Target Platform**: mobile et web (limite de stockage du navigateur d'environ 5 Mo, d'où la borne)

**Project Type**: application mobile Flutter

**Performance Goals**: rendre la main à l'utilisateur après 15 s au plus (délai du client HTTP)

**Constraints**: hors ligne obligatoire après un premier lancement ; un échec n'est jamais mis en cache (principe II) ; aucun test ne touche le réseau

**Scale/Scope**: 5 documents globaux (`versions`, `champions`, `items`, `runes`, `summoners`) et jusqu'à 12 fiches de champions

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté | `lib/data_dragon/` (service, exception, cache) ; les services consommateurs restent dans leurs dossiers (`lib/champions/services/`, `lib/items/services/`, `lib/runes/services/`, `lib/summoner_spells/services/`) |
| II. Données Riot via Data Dragon, erreurs affichables | Respecté | Tout passe par `DataDragonService.fetchJson` ; toute panne devient `DataDragonException` ; `_pendingVersion` remis à `null` en cas d'échec ; `ErrorRetryView` ajouté à la page de la carte (`lib/map/map_page.dart`) ; aucune clé API |
| III. Images via RemoteImage | Sans objet | Les images sont hors périmètre |
| IV. Thème centralisé | Sans objet | Aucun style nouveau (la vue d'erreur existait) |
| V. État simple et local | Respecté | `shared_preferences` ; `MapPage` reste un `StatefulWidget` avec `setState` ; pas de nouveau paquet d'état |
| VI. Tests | Respecté en partie | `test/data_dragon/data_dragon_service_test.dart` (8 cas), `test/champions/services/champion_service_offline_test.dart`, `test/map/map_page_retry_test.dart` ; pas de test direct d'`OfflineJsonCache`, ni de `ItemService`, `RuneService`, `SummonerSpellService` sur ce point |
| VII. Lisibilité, français | Respecté, avec réserve | Commentaires qui expliquent le pourquoi ; `_detailCopiesKept = 12` nommée ; messages d'erreur en français. Les messages « Le serveur de Riot a répondu 503. » n'utilisent pas le tutoiement, seul le message de connexion s'adresse à l'utilisateur (« Vérifie ta connexion ») |

## Project Structure

### Documentation (this feature)

```text
specs/002-donnees-hors-ligne/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── data-dragon-service.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── data_dragon/
│   ├── data_dragon_exception.dart       # panne avec message affichable
│   ├── data_dragon_service.dart         # fetchJson(offlineKey, isValid, offlineKeepLast), latestVersion, hasDataMap
│   └── offline_json_cache.dart          # copie shared_preferences + borne par famille
├── champions/services/champion_service.dart   # champions + fiche champion:<id>
├── items/services/item_service.dart
├── runes/services/rune_service.dart
├── summoner_spells/services/summoner_spell_service.dart
├── map/map_page.dart                    # loadVersion injectable, ErrorRetryView + Réessayer
└── shared/
    ├── errors/user_message.dart         # userMessageFor
    └── widgets/error_retry_view/error_retry_view.dart

test/
├── data_dragon/data_dragon_service_test.dart
├── champions/services/champion_service_offline_test.dart
└── map/map_page_retry_test.dart

docs/agents/reports/offline-audit.md     # audit à l'origine du durcissement
```

**Structure Decision**: structure existante conservée ; `OfflineJsonCache` est un nouveau fichier du dossier `data_dragon`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe VI : `OfflineJsonCache` et les services objets, runes, sorts sans test direct | Le comportement passe par `fetchJson`, qui est testé | Dette reconnue : le branchement de `isValid` dans ces trois services n'a pas de test |
| Principe VII : messages de panne sans tutoiement | Messages factuels (« Le serveur de Riot a répondu 503. ») | Seul le message de connexion s'adresse à l'utilisateur ; écart mineur non corrigé |
