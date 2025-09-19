"! Repository Interface: definiert die Domänen-Sicht auf Datenzugriff
INTERFACE zif_rev_repo PUBLIC.

  TYPES: BEGIN OF ty_rev_row,
           carrid   TYPE s_carr_id,
           carrname TYPE scarr-carrname,
           currency TYPE sflight-currency,
           flights  TYPE i,
           seats    TYPE i,
           revenue  TYPE p DECIMALS 2,
         END OF ty_rev_row,
         ty_rev_tab TYPE STANDARD TABLE OF ty_rev_row WITH DEFAULT KEY.

  METHODS get_revenue
    IMPORTING
      i_date_from TYPE sflight-fldate
      i_date_to   TYPE sflight-fldate
      i_carrid    TYPE s_carr_id OPTIONAL
      it_curr     TYPE RANGE OF sflight-currency OPTIONAL
    RETURNING VALUE(rt_data) TYPE ty_rev_tab
    RAISING   cx_static_check.

ENDINTERFACE.
