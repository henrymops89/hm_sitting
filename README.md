# 🪑 HM Sitting – Chair Sit System

**by MopsScripts**

Ein FiveM Script das es Spielern ermöglicht, sich auf Stühle, Bänke, Sofas und andere Sitz-Props zu setzen. Unterstützt **ox_target**, **qb-target** und **ESX E-Key**.

---

## 📦 Abhängigkeiten

| Framework | Benötigt |
|-----------|----------|
| **ox_target** (QBox / QBCore) | `ox_target`, `ox_lib` |
| **qb-target** | `qb-target` |
| **ESX** | `ox_lib` (für drawText Prompt) |

---

## 📁 Dateistruktur

```
hm-sitting/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── target.lua
```

---

## ⚙️ Installation

1. Ordner `hm-sitting` in dein `resources` Verzeichnis legen
2. In der `server.cfg` eintragen:
   ```
   ensure hm_sitting
   ```
3. In der `config.lua` das gewünschte Target-System einstellen (siehe unten)

---

## 🔧 Konfiguration

Alle Einstellungen befinden sich in der `config.lua`.

### Target-System auswählen

```lua
Config.TargetSystem = 'ox'   -- ox_target  (QBox / QBCore)
Config.TargetSystem = 'qb'   -- qb-target  (QBCore)
Config.TargetSystem = 'esx'  -- E-Key Prompt (ESX + ox_lib)
```

### Weitere Einstellungen

```lua
-- Suchradius für ESX E-Key (in Metern)
Config.SearchRadius = 2.0

-- Sitz-Animation
Config.Anim = {
    dict = 'amb@world_human_tourist_mobile@male@base',
    clip = 'base',
}

-- Höhen-Offset damit der Spieler korrekt auf dem Stuhl sitzt
Config.SitOffset = vector3(0.0, 0.0, 0.35)
```

### Eigene Props hinzufügen

In `config.lua` einfach einen weiteren Prop-Namen in die Liste eintragen:

```lua
Config.ChairProps = {
    'prop_chair_01a',
    'mein_custom_prop', -- << einfach hinzufügen
    ...
}
```

---

## 🎮 Nutzung im Spiel

| System | Aktion |
|--------|--------|
| ox_target / qb-target | Stuhl anschauen → Interaktions-Menü → **Hinsetzen** |
| ESX E-Key | In die Nähe eines Stuhls gehen → **[E] Hinsetzen** |
| Aufstehen | **WASD** drücken (alle Frameworks) |

---

## 🪑 Unterstützte Props

Das Script unterstützt über **200 GTA V Sitz-Props**, darunter:

- Stühle (`prop_chair_*`)
- Bänke (`prop_bench_*`)
- Bar Stools (`prop_bar_stool_*`)
- Armchairs (`prop_armchair_*`)
- Couches (`prop_couch_*`)
- Office Chairs (`prop_off_chair_*`)
- Pool Lounger (`prop_pool_lounger_*`)
- Interior Props (`apa_mp_h_*`, `ex_mp_h_*`, `hei_heist_*`, `v_res_*`, `v_serv_ct_*`, u.v.m.)

Die vollständige Liste ist in der `config.lua` einsehbar und jederzeit erweiterbar.

---

## 📝 Changelog

### v1.0.0
- Initial Release
- Multi-Framework Support: ox_target, qb-target, ESX E-Key
- Über 200 Sitz-Props vorkonfiguriert
- Automatisches Aufstehen bei Bewegung
- Cleanup beim Resource Stop

---

## 🛠️ Support

Bei Fragen oder Problemen: **MopsScripts Discord**
