# Spécifications spec-kit rédigées après coup — consignes communes

Lis d'abord `docs/agents/COORDINATION.md` (§2 contexte, §3 règles, §6 journal).

## Contexte
Le projet est installé avec **spec-kit** (`.specify/`, modèles dans
`.specify/templates/`, constitution dans `.specify/memory/constitution.md`,
numérotation **séquentielle**). Les fonctionnalités ci-dessous ont été
construites sans passer par `/speckit-specify`, `-plan`, `-tasks`. Ta mission :
écrire, pour chacune des tiennes, **le dossier de spécification tel que spec-kit
l'aurait produit**, d'après le **code réellement livré**, `git log` et les tests.
Le contenu doit être **exact** : tu documentes ce qui existe, pas ce qui
aurait pu exister.

## Ce que tu produis, par fonctionnalité `specs/NNN-nom/`
Lis d'abord `.specify/templates/spec-template.md`, `plan-template.md`,
`tasks-template.md`, `checklist-template.md` et respecte leur structure (sections,
titres, numérotation `FR-001`, `SC-001`, `US1`…), **sans** laisser de texte modèle
ni de `[PLACEHOLDER]`.

1. **`spec.md`** — `Feature Branch` : `NNN-nom` (écris « travail livré sur
   `main` » à côté) ; `Created` : la date du premier commit de la
   fonctionnalité ; `Status` : `Implemented` (ou `In Progress` si indiqué dans ta
   fiche) ; `Input` : **la demande réelle de l'utilisateur, citée** (elle est
   dans ta fiche). Puis : parcours utilisateur priorisés P1/P2/P3 (chacun avec
   « Why this priority », « Independent Test », scénarios *Given/When/Then*),
   cas limites **vérifiés dans le code ou les tests**, exigences fonctionnelles
   `FR-xxx` (sans parler d'implémentation : « le système DOIT… »), entités
   clés, critères de réussite **mesurables et indépendants de la technologie**
   `SC-xxx`, hypothèses. Aucun `[NEEDS CLARIFICATION]` : tout est tranché par le
   code.
2. **`plan.md`** — résumé, **Technical Context** réel (Dart 3 / Flutter
   `^3.13`, dépendances utilisées par cette fonctionnalité, stockage
   `shared_preferences`/fichier embarqué/aucun, tests `flutter_test`, plateformes
   mobile + web, contraintes hors-ligne…), **Constitution Check** : pour chacun
   des 7 principes de `.specify/memory/constitution.md`, dis **honnêtement** si
   la fonctionnalité le respecte, avec le fichier qui le prouve ; une entorse
   réelle va dans **Complexity Tracking** (avec sa justification), **ne mens
   pas**. Structure du code : l'arborescence **réelle** (`lib/…`, `test/…`).
3. **`research.md`** — les décisions techniques qui ne vont pas de soi
   (pourquoi tel seuil, tel format, tel repli), « Decision / Rationale /
   Alternatives considered », tirées des commentaires du code (« pourquoi »), des
   messages de commit et des tests. N'invente pas d'alternative qui n'a pas de
   trace : si tu ne sais pas, écris-le.
4. **`data-model.md`** — entités, champs, validations, relations, états
   (ex. une draft, une build). Ignore ce fichier seulement si la fonctionnalité
   ne manipule aucune donnée ; dis-le alors dans `plan.md`.
5. **`contracts/`** — un fichier Markdown par **interface publique** utile à
   d'autres modules (signatures Dart des services/widgets/format de code de
   partage/format JSON de fichier de données…). Omis si aucune interface n'est
   consommée ailleurs.
6. **`quickstart.md`** — scénarios de validation à la main (lancer l'appli,
   ouvrir tel écran, faire tel geste, résultat attendu) **et** les commandes de
   test exactes de la fonctionnalité (`flutter test test/…`).
7. **`tasks.md`** — au format `tasks-template.md` : `T001 [P] [US1] Description
   avec chemin exact`, organisé par parcours utilisateur, phases Setup /
   Foundational / US1… / Polish. **Toutes les tâches sont cochées `[x]`** (c'est
   livré) et chaque tâche pointe un **fichier qui existe vraiment** : vérifie
   chaque chemin avec `ls`/`Glob`. Inclus les tâches de tests.
8. **`checklists/requirements.md`** — d'après `checklist-template.md` : qualité de
   la spécification (aucun détail d'implémentation dans `spec.md`, exigences
   testables, critères mesurables, cas limites couverts…). Coche ce qui est
   vrai, ne coche pas ce qui ne l'est pas.

## Vérité d'abord
- Lis le code (`lib/<feature>/…`, `test/<feature>/…`) et `git log --stat -- <chemins>`
  avant d'écrire. Les messages de commit sont en français et utiles.
- Chaque FR doit avoir au moins un test ou un comportement observable dans le
  code ; cite-le dans `tasks.md` ou `quickstart.md`.
- Si le code **diverge** de la demande de l'utilisateur ou comporte un défaut
  connu, **écris-le** dans `spec.md` (section « Hypothèses et limites connues »)
  plutôt que de l'embellir.
- Langue : **français** (comme la constitution), identifiants de code en anglais.
- **N'invente pas de dates** : utilise celles de `git log --date=short`. Les
  fonctionnalités n'ont jamais eu de branche dédiée : tout est sur `main`.

## Interdits
Ne modifie **aucun** fichier hors de `specs/` (ni `lib/`, ni `test/`, ni
`.specify/`). Ne commite pas. N'utilise ni `/speckit-*` ni les scripts
`.specify/scripts` (ils créent des branches). Écris tes fichiers avec l'outil
Write, un par un.

## Fin de tâche
Relis **un** de tes dossiers de bout en bout pour traquer les placeholders ; lance
`ls -R specs/<tes dossiers>` pour vérifier que les 7 à 8 éléments existent ; mets
une ligne au journal ; réponds par un compte rendu court (dossiers créés,
écarts découverts entre code et demande, points douteux).
