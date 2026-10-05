# Research: Carte du dernier patch

## Un lien plutôt que le contenu des notes

- **Decision**: la carte n'affiche que le numéro du patch et un lien vers la page officielle.
- **Rationale**: « Riot ne publie pas le contenu des notes dans une API : on ne retient que le numéro de patch et l'adresse de la page officielle » (commentaire de `PatchNotes`).
- **Alternatives considered**: récupérer et afficher le texte des notes ; non retenu pour la raison ci-dessus. Aucune autre alternative n'a laissé de trace.

## Numéro du site = saison + 10

- **Decision**: `year = season + 10` ; `label = "$year.$patch"` (« 16.19.1 » donne « 26.19 »).
- **Rationale**: « les numéros de patch publiés sur le site portent l'année de la saison (26.19), alors que Data Dragon garde le numéro de saison seul (16.19) » ; constante nommée `_seasonOffset = 10`. Test `déduit le patch du site de la version Data Dragon`.
- **Alternatives considered**: aucune trace. Le décalage est supposé constant dans le temps (non vérifié).

## Motif de l'adresse

- **Decision**: `https://www.leagueoflegends.com/fr-fr/news/game-updates/league-of-legends-patch-<année>-<patch>-notes`.
- **Rationale**: motif des pages françaises ; vérifié par le test sur la chaîne produite, **pas** par une requête réelle.
- **Alternatives considered**: aucune trace.

## Version illisible = pas de carte

- **Decision**: `PatchNotes.fromVersion` renvoie `null` si la version a moins de deux parties ou si saison ou patch ne sont pas des entiers ; la carte est alors omise.
- **Rationale**: « La carte du patch est un bonus : sans la version du jeu, elle est simplement absente et l'accueil reste complet » (commentaire de `HomePage.loadPatchNotes`). Test `refuse une version illisible`.
- **Alternatives considered**: afficher un message d'erreur ou un « Réessayer » (non retenu : le bonus ne mérite pas de bruit).

## Chargement indépendant de l'accueil

- **Decision**: `loadPatchNotes()` est lancée en parallèle de `loadData()` et ignore silencieusement ses échecs.
- **Rationale**: éviter qu'une panne de version ne bloque l'accueil ; `DataDragonService.latestVersion()` mémorise le futur, de sorte que deux écrans ouverts ensemble n'interrogent pas `versions.json` deux fois.
- **Alternatives considered**: aucune trace.

## Ouverture externe et échec

- **Decision**: `launchUrl(..., mode: LaunchMode.externalApplication)` ; si le retour est faux, un `SnackBar` dit « Impossible d'ouvrir les notes de patch. ».
- **Rationale**: sortir de l'application vers le navigateur pour un site Riot ; le message évite un appui sans effet. Le `ScaffoldMessenger` est capté avant l'`await` pour ne pas utiliser un contexte après une attente.
- **Alternatives considered**: aucune trace. Une exception de `launchUrl` n'est pas rattrapée dans le code actuel (seul le retour `false` l'est).
