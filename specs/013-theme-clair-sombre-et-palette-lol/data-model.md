# Modèle de données : Thème clair / sombre et palette du client LoL

## ThemeMode (type Flutter, valeur choisie par l'utilisateur)

| Valeur | Sens | Libellé affiché | Description affichée |
|--------|------|-----------------|----------------------|
| `system` | suit l'appareil (défaut) | Automatique | Suit le réglage de l'appareil |
| `light` | toujours clair | Clair | Fond clair, lisible en plein jour |
| `dark` | toujours sombre | Sombre | Fond sombre, reposant le soir |

**Persistance** : `shared_preferences`, clé `theme_mode`, valeur = `ThemeMode.name` (`system` | `light` | `dark`).
**Validation** : toute valeur absente ou inconnue se lit comme `system`.

## Luminosité effective (`Brightness`)

Calculée par `ThemeService.resolve(chosen, device)` :

| Mode choisi | Luminosité appareil | Résultat |
|-------------|---------------------|----------|
| `light` | quelconque | clair |
| `dark` | quelconque | sombre |
| `system` | clair / sombre | celle de l'appareil |

## AppPalette (huit couleurs)

| Champ | Sombre | Clair |
|-------|--------|-------|
| `background` | `#010A13` | `#F3EEE2` |
| `surface` | `#0A1428` | `#FBF8F1` |
| `accent` | `#C8AA6E` | `#7A5C1E` |
| `textPrimary` | `#F0E6D2` | `#0A1428` |
| `textSecondary` | parchemin à 0,62 d'opacité | `#0A1428` à 0,74 |
| `textMuted` | parchemin à 0,55 | `#0A1428` à 0,64 |
| `border` | or à 0,22 | brun doré (120, 90, 40) à 0,28 |
| `accentSoft` | or à 0,14 | or foncé à 0,12 |

**Contraintes** (testées) : texte principal, secondaire, discret ≥ 4,5:1 sur `background`, `surface` et sur `accentSoft` posé sur `background` (puce sélectionnée) ; `accent` ≥ 4,5:1 sur `background`, `surface` et la puce sélectionnée.

## État de session

- `ThemeService.mode` : `ValueNotifier<ThemeMode>`, valeur initiale `system`.
- `AppColors._palette` : palette active, `dark` au départ ; `AppColors.isDark` vrai si la palette active est la sombre.
- Transitions : choix dans la feuille → `setMode` → notification → `MyApp._applyBrightness` ; changement d'appareil → `didChangePlatformBrightness` → `_applyBrightness`. Si la luminosité effective est inchangée, rien ne se passe.
