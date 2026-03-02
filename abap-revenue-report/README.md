# ABAP Revenue Report

Showcase-Projekt zur Demonstration von sauberem, testbarem OO-ABAP.
Die Anwendung aggregiert Flugumsätze pro Carrier/Währung und stellt die Ergebnisse als SALV-Report dar.

## 1) Projektziel
Dieses Projekt zeigt, wie ein klassischer Report technisch sinnvoll in Schichten getrennt wird:
- `Report` als schlanker Einstiegspunkt
- `App` für Orchestrierung und Autorisierung
- `Service` für fachliche Logik (Validierung, Filter, Sortierung)
- `Repository` für Datenzugriff
- `Exception` für konsistente Fehlerkommunikation

Damit ist der Code sowohl wartbar als auch gut testbar.

## 2) Fachlicher Scope
Grundlage sind SAP-Standardtabellen:
- `SFLIGHT` (Flug- und Preisdaten)
- `SCARR` (Carrier-Stammdaten)

Berechnung:
- Revenue je Datensatz = `price * seatsocc`
- Aggregation nach `carrid` + `currency`
- Zusätzliche Kennzahlen: Anzahl Flüge, belegte Sitze

## 3) Funktionsumfang
- Datumsfilter (`von/bis`, Pflichtfelder)
- Optionaler Carrier-Filter
- Optionaler Währungsfilter (`SELECT-OPTIONS`)
- Mindestumsatz-Filter
- Sortierung nach Umsatz (auf-/absteigend)
- SALV-Ausgabe mit optimierten Spalten und Standardfunktionen
- Fehlerfälle über eigene Exception-Klasse `ZCX_REV_APP`
- ABAP Unit Tests für zentrale Service-Logik

## 4) Technischer Aufbau
- Einstieg: `src/zrevenue_carrier_report.prog.abap`
- Orchestrierung/UI/Auth: `src/zcl_rev_app.clas.abap`
- Business-Logik: `src/zcl_rev_service.clas.abap`
- Data Access: `src/zcl_rev_repo_dbtab.clas.abap`
- Repository-Contract: `src/zif_rev_repo.intf.abap`
- Fachliche Fehler: `src/zcx_rev_app.clas.abap`

Details siehe [docs/architecture.md](docs/architecture.md).

## 5) Selektionsparameter
| Parameter | Typ | Bedeutung |
|---|---|---|
| `p_from` | `SFLIGHT-FLDATE` | Startdatum (obligatorisch) |
| `p_to` | `SFLIGHT-FLDATE` | Enddatum (obligatorisch) |
| `p_carr` | `S_CARR_ID` | Optionaler Carrier |
| `so_curr` | Range `SFLIGHT-CURRENCY` | Optionale Währungsfilter |
| `p_min` | `P DEC 2` | Mindestumsatz |
| `p_sort` | Checkbox | Sortierung aktiv |
| `p_desc` | Checkbox | Sortierung absteigend |

## 6) Ausführung
1. Projekt via `abapGit` ins SAP-System importieren.
2. Report `ZREVENUE_CARRIER_REPORT` starten.
3. Selektionsparameter setzen und ausführen.
4. Ergebnisse im SALV prüfen.

## 7) Qualitätssicherung
### ABAP Unit
Tests sind als lokale Testklassen in `zcl_rev_service.clas.abap` enthalten (`LTC_SERVICE`):
- Validierungsfehler bei ungültigem Datumsbereich
- Filterlogik für Mindestumsatz
- Sortierverhalten bei absteigender Umsatzausgabe

### Linting / Konventionen
`tooling/abaplint.json` enthält zentrale Regeln, u. a.:
- ABAP Doc aktiv
- Naming/Indentation/Line-Length
- Verbot kritischer Statements wie `WRITE`, `UNDO`, `COMMIT WORK`
- Ziel-Release `755`

## 8) Fehlerbehandlung
Typische Fehlerpfade:
- Ungültiger Datumsbereich (`from > to`)
- Keine Treffer für gewählte Filter
- Keine Berechtigung auf Transaktion (`AUTHORITY-CHECK` auf `S_TCODE`)

Alle fachlichen Fehler laufen über `ZCX_REV_APP` und werden im Report abgefangen.

## 9) Bewerbungsrelevante Skills (aus dem Code ableitbar)
- ABAP Objects (Klassen, Interfaces, Kapselung)
- Schichtenarchitektur und SOLID-nahe Trennung
- Dependency Injection und testbare Business-Logik
- ABAP Unit / Test Doubles
- Performante interne Tabellen (`HASHED`, `SORTED`)
- Standard-UI mit SALV
- Sichere Eingabevalidierung und Fehlerpfade

## 10) Mögliche Erweiterungen
- CDS- oder Open-SQL-Variante der Aggregation
- Ausgabe zusätzlich als OData/Fiori-Backend
- Erweiterte Autorisierungen statt reinem `S_TCODE`-Check
- Automatisierter CI-Run von `abaplint` in einer Pipeline
