# Research : Barre de navigation

## 1. Widget `AppNavBar` autonome

- **Decision**: extraire la barre dans `AppNavBar`, qui reçoit `destinations`, `currentIndex` et `onSelect`, sans connaître les pages.
- **Rationale**: message du commit `b9132b1` : la barre est « extraite dans son propre widget et testée ». Cela permet de la tester avec deux destinations factices (`test/main_navigation/app_nav_bar_test.dart`).
- **Alternatives considered**: `NavigationBar` / `BottomNavigationBar` de Material : aucune trace d'évaluation dans le code ou les commits ; le choix d'un widget maison n'est pas expliqué.

## 2. Indicateur d'onglet actif en trait doré animé

- **Decision**: un `AnimatedContainer` de 3 px de haut, 28 px de large quand l'onglet est actif, 0 sinon, qui reste présent (transparent par largeur nulle) sur les inactifs.
- **Rationale**: commentaire du code : « le trait reste présent sur les onglets inactifs : la hauteur de la barre ne bouge pas quand l'onglet change ».
- **Alternatives considered**: non documentées.

## 3. Trois signaux pour l'onglet actif

- **Decision**: trait + icône pleine (`selectedIcon`) + libellé en gras `w700` et couleur d'accent ; inactifs en `textMuted` et icône au trait.
- **Rationale**: la demande était que la barre « fasse plus navbar ». Le test vérifie l'icône pleine de l'actif et l'icône au trait des autres. Ne pas reposer sur la seule couleur est cohérent avec le chantier d'accessibilité (voir `docs/agents/reports/a11y-audit.md`), mais aucun commentaire ne le dit.

## 4. Sémantique exposée par l'onglet et non par ses enfants

- **Decision**: `Semantics(button: true, selected: selected, label: ..., excludeSemantics: true, onTap: onTap)`.
- **Rationale**: l'ancienne barre (commit antérieur à `b9132b1`) avait déjà cette sémantique ; elle est conservée pour que l'icône et le texte ne soient pas lus séparément. Testé par « marque l'onglet actif pour les lecteurs d'écran ».

## 5. Surface et filet

- **Decision**: `DecoratedBox` de couleur `AppColors.surface` avec une bordure haute `AppColors.border`, dans un `SafeArea(top: false)`.
- **Rationale**: commentaire de la classe : « un filet doré qui la sépare de la page ». L'ancienne barre avait le fond de la page, donc se fondait dans le contenu (cause probable du « ne fait pas trop navbar », hypothèse non écrite dans le code).

## 5 bis. Libellé réduit plutôt que tronqué

- **Decision**: `FittedBox(fit: BoxFit.scaleDown)` autour du libellé.
- **Rationale**: la barre compte six onglets ; sur écran étroit, un libellé comme « Champions » doit rester entier. L'ancienne barre utilisait déjà ce mécanisme.

## 6. Onglets construits à la première visite

- **Decision**: `visitedTabs` + `IndexedStack`, `SizedBox.shrink()` pour un onglet non visité.
- **Rationale**: commentaire de `main_navigation.dart` : retrouver défilement, recherche et filtres, sans télécharger au démarrage les données des onglets jamais visités. Comportement antérieur (`6ea513f`), non modifié par cette fonctionnalité.
