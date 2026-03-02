# Bewerbungsprofil: ABAP Revenue Report

## Kurzbeschreibung (für CV/GitHub/Anschreiben)
Eigenständiges ABAP-Showcase zur Umsatzaggregation auf Basis von SAP-Flugdaten (`SFLIGHT`/`SCARR`) mit klarer Schichtenarchitektur, testbarer Business-Logik und SALV-UI.

## Technische Kernaussagen
- Saubere Trennung von UI, Fachlogik und Datenzugriff
- Dependency Injection über Interface (`ZIF_REV_REPO`) für austauschbare Datenquellen
- Robuste Fehlerbehandlung via fachlicher Exception (`ZCX_REV_APP`)
- ABAP Unit mit Test Double zur isolierten Prüfung der Service-Logik
- Nutzung performanter interner Tabellenstrukturen (`HASHED`, `SORTED`)

## Was dieses Projekt über den Entwickler zeigt
- Strukturierte Herangehensweise statt monolithischem Report-Code
- Fokus auf Wartbarkeit und Erweiterbarkeit
- Verständnis für Testbarkeit in klassischem ABAP-Umfeld
- Sicherheitsbewusstsein durch integrierte Berechtigungsprüfung

## Gesprächsleitfaden für Interviews
### Architektur
Warum eine Service-/Repository-Trennung?
- Business-Regeln bleiben unabhängig vom Datenzugriff.
- Spätere Umstellung auf CDS/OData ist technisch einfacher.

### Testbarkeit
Warum DI in ABAP?
- Kernlogik ist ohne DB und ohne UI testbar.
- Unit-Tests sind stabil, schnell und reproduzierbar.

### Fachlogik
Warum Mindestumsatz und Sortieroptionen?
- typische analytische Anforderungen wurden direkt in die Domänelogik integriert.
- Verhalten bleibt durch Tests abgesichert.

### Sicherheit und Fehlerfälle
Welche Risiken werden abgefangen?
- ungültige Eingaben
- leere Ergebnismengen
- fehlende Berechtigungen

## Beispieltext für Bewerbungen
In einem eigenen ABAP-Showcase habe ich einen Revenue-Report mit klarer Schichtenarchitektur umgesetzt. Dabei habe ich Datenzugriff und Fachlogik über ein Repository-Interface entkoppelt, die Business-Regeln testbar gestaltet (ABAP Unit mit Test Double) und eine robuste Fehlerbehandlung über eine eigene Exception-Klasse eingeführt. Das Ergebnis ist ein wartbarer, erweiterbarer Report mit SALV-Ausgabe, der typische Anforderungen aus Reporting- und Analyse-Szenarien abdeckt.
