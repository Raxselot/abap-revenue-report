# Architektur: ABAP Revenue Report

## 1) Kontext
Die Anwendung aggregiert Revenue-Daten aus `SFLIGHT` und reichert sie mit Carrier-Informationen aus `SCARR` an.
Das Ergebnis wird als ALV-Tabelle (SALV) dargestellt.

Ziel der Architektur:
- fachliche Logik von Infrastruktur trennen
- Testbarkeit durch Dependency Injection sicherstellen
- Fehlerpfade konsistent handhaben

## 2) Schichtenmodell
### Report-Layer
- Objekt: `ZREVENUE_CARRIER_REPORT`
- Verantwortung:
  - Selektionsscreen bereitstellen
  - Einstiegspunkt (`START-OF-SELECTION`)
  - Top-Level Exception Handling (`ZCX_REV_APP`)

### App-Layer
- Objekt: `ZCL_REV_APP`
- Verantwortung:
  - Autorisierung prüfen (`AUTHORITY-CHECK` auf `S_TCODE`)
  - Service/Repository instanziieren
  - Selektionsparameter an Service übergeben
  - SALV-Ausgabe konfigurieren und anzeigen

### Service-Layer
- Objekt: `ZCL_REV_SERVICE`
- Verantwortung:
  - Eingaben validieren (z. B. Datumsbereich)
  - Repository-Aufruf kapseln
  - Nachgelagerte Fachlogik (Mindestumsatz, Sortierung)
  - Fachliche Fehler via `ZCX_REV_APP` werfen

### Repository-Layer
- Contract: `ZIF_REV_REPO`
- Implementierung: `ZCL_REV_REPO_DBTAB`
- Verantwortung:
  - Daten aus `SFLIGHT` lesen
  - Carrier-Namen aus `SCARR` ermitteln
  - Aggregation nach `(CARRID, CURRENCY)` durchführen
  - Ergebnis in domänenspezifischem Tabellentyp zurückgeben

### Error-Layer
- Objekt: `ZCX_REV_APP`
- Verantwortung:
  - einheitliche fachliche Ausnahmetypen
  - klare Fehlermeldungen für UI/Benutzerführung

## 3) Laufzeitfluss
1. Benutzer startet `ZREVENUE_CARRIER_REPORT` und setzt Filter.
2. Report ruft `ZCL_REV_APP->run( )` auf.
3. App prüft Berechtigung und initialisiert `ZCL_REV_SERVICE` mit Repository.
4. Service validiert Input und ruft `ZIF_REV_REPO~GET_REVENUE` auf.
5. Repository liest/aggregiert Daten und liefert Ergebnistabelle.
6. Service filtert/sortiert Ergebnis gemäß Parametern.
7. App zeigt Resultat über SALV.
8. Fehler werden über `ZCX_REV_APP` nach oben gereicht und im Report angezeigt.

## 4) Teststrategie
Die Business-Logik liegt im Service und ist dadurch isoliert testbar.

Umsetzung:
- DI über Konstruktor (`io_repo TYPE REF TO zif_rev_repo`)
- Test-Double (`LCL_REPO_DOUBLE`) in ABAP Unit
- Tests in `LTC_SERVICE`:
  - Input-Validierung
  - Mindestumsatz-Filter
  - Sortierreihenfolge

Ergebnis:
- keine Datenbankabhängigkeit in den Unit-Tests
- schneller, deterministischer Testlauf

## 5) Designentscheidungen und Trade-offs
- Pro: klare Schichtung erhöht Wartbarkeit und Lesbarkeit.
- Pro: DI reduziert Kopplung und macht Tests robust.
- Pro: SALV ist schnell integrierbar und für klassische Reports ausreichend.
- Trade-off: Aggregation erfolgt aktuell in ABAP (In-Memory), nicht als DB-Aggregat.
- Trade-off: Autorisierung ist bewusst minimal gehalten (`S_TCODE`) und muss in produktiven Szenarien feiner modelliert werden.

## 6) Erweiterbarkeit
Naheliegende Erweiterungen:
- alternative Repository-Implementierung (z. B. CDS/View) ohne Änderung am Service
- zusätzliche Kennzahlen (Load Factor, Yield)
- Exportfunktion (CSV/XLSX)
- Service als API/OData wiederverwendbar

Die Architektur erlaubt diese Erweiterungen mit überschaubarem Änderungsumfang, weil das Kernverhalten über Interfaces und Schichten entkoppelt ist.
