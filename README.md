# ABAP Revenue Report Showcase

Dieses Repository zeigt eine kompakte, produktionsnahe ABAP-Anwendung zur Umsatzaggregation auf Basis von `SFLIGHT` und `SCARR`.

Der Fokus liegt auf sauberer Architektur statt nur auf Ergebnisanzeige:
- objektorientiertes Design mit klarer Schichtenaufteilung
- Dependency Injection für Testbarkeit
- robuste Fehlerbehandlung mit eigener Exception-Klasse
- UI-Ausgabe mit SALV
- ABAP Unit Tests für Kernlogik

## Repository-Struktur
```text
.
|-- README.md                               <- Überblick (dieses Dokument)
`-- abap-revenue-report/
    |-- README.md                           <- Technische Projektdokumentation
    |-- docs/
    |   |-- architecture.md                 <- Architektur- und Designentscheidungen
    |   `-- application-profile.md          <- Bewerbungs-/Interview-Zusammenfassung
    |-- src/
    |   |-- zrevenue_carrier_report.prog.abap
    |   |-- zcl_rev_app.clas.abap
    |   |-- zcl_rev_service.clas.abap
    |   |-- zcl_rev_repo_dbtab.clas.abap
    |   |-- zif_rev_repo.intf.abap
    |   `-- zcx_rev_app.clas.abap
    `-- tooling/
        `-- abaplint.json
```

## Einstieg
1. Öffne die ausführliche Projektdoku unter [abap-revenue-report/README.md](abap-revenue-report/README.md).
2. Lies die Architektur unter [abap-revenue-report/docs/architecture.md](abap-revenue-report/docs/architecture.md).
3. Nutze die Kurzfassung für Bewerbungen unter [abap-revenue-report/docs/application-profile.md](abap-revenue-report/docs/application-profile.md).

## Hinweis
Das Projekt ist als Showcase für sauberes ABAP-Engineering gedacht. Inhalte lassen sich direkt in Bewerbungsunterlagen, GitHub-Profil und Fachgesprächen verwenden.
