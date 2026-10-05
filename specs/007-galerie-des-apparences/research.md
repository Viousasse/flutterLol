# Research: Galerie des apparences

## Écarter les variantes de couleur

- **Decision**: `ChampionSkin.listFromJson` ignore toute entrée qui porte une clé `parentSkin`.
- **Rationale**: « les variantes de couleur (chromas) […] n'ont pas d'illustration propre : elles portent un `parentSkin` » (commentaire). Test `écarte les variantes de couleur, qui n ont pas d illustration` (`Ahri popstar (améthyste)` exclue).
- **Alternatives considered**: les lister avec l'illustration de leur parent ; aucune trace dans le code.

## Deux illustrations selon la taille

- **Decision**: vignettes en `loading` (verticale, légère), plein écran en `splash` (horizontale, grande).
- **Rationale**: commentaires de `ChampionSkin` ; principe III de la constitution (source choisie selon la taille d'affichage). Test `construit les adresses des illustrations`.
- **Alternatives considered**: une seule illustration pour les deux usages (non retenu, aucune trace d'essai).

## Adresse construite à la main

- **Decision**: `https://ddragon.leagueoflegends.com/cdn/img/champion/{splash|loading}/<ChampionId>_<num>.jpg`, sans numéro de version de jeu.
- **Rationale**: les illustrations d'apparences se trouvent sous `cdn/img/champion` (chemin non versionné). Aucun commentaire ne le justifie plus avant.
- **Alternatives considered**: aucune trace.

## Nom de l'apparence d'origine

- **Decision**: l'entrée nommée « default » par Riot devient « Apparence classique » (constante `defaultName`).
- **Rationale**: interface en français (principe VII) ; test `nomme l apparence d origine en français`.
- **Alternatives considered**: aucune trace.

## Section masquée avec une seule apparence

- **Decision**: la section n'apparaît que si `detail.skins.length > 1`.
- **Rationale**: avec une seule apparence (l'origine), une galerie n'apporte rien ; aucun commentaire ne le dit explicitement, la condition est dans `champion_detail_page.dart`.
- **Alternatives considered**: aucune trace.

## Visualiseur : PageView, flèches, InteractiveViewer

- **Decision**: `PageView.builder` (glisser), `InteractiveViewer(maxScale: 4)` (pincer), deux flèches `IconButton` avec infobulle, titre « n / total » dans la barre, nom en bas ; durée de glissement de 250 ms (`_slide`).
- **Rationale**: commentaire de classe « on glisse ou on appuie sur les flèches pour passer de l'une à l'autre, on pince pour zoomer ». Les flèches servent sur le web, où l'on ne glisse pas facilement.
- **Alternatives considered**: aucune trace.

## Un seul appui pour ouvrir

- **Decision**: toute la vignette (image et nom) est un bouton sémantique « Voir <nom> en grand ».
- **Rationale**: cohérence avec l'accessibilité des autres cartes de l'application (libellé + `excludeSemantics`).
- **Alternatives considered**: aucune trace.
