# Architektur
- **Domain**: Revenue-Aggregation auf SFLIGHT/SCARR
- **Schichten**:
  - `ZIF_REV_REPO` (Interface) – Datenzugriff
  - `ZCL_REV_REPO_DBTAB` – konkrete Repo-Implementierung
  - `ZCL_REV_SERVICE` – Validierung, Filter, Sortierung
  - `ZCL_REV_APP` – Orchestrierung, AUTH, UI (SALV)
  - `ZCX_REV_APP` – fachliche Fehler
- **Testbarkeit**: DI -> Test Double für Repo; ABAP Unit im Service
- **Security**: `AUTHORITY-CHECK` (S_TCODE), erweiterbar
