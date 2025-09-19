"! App/Orchestrierung: AUTH, Aufruf Service, SALV-UI
CLASS zcl_rev_app DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run RAISING zcx_rev_app.
  PRIVATE SECTION.
    METHODS:
      check_auth RAISING zcx_rev_app,
      display_alv IMPORTING it_data TYPE zif_rev_repo=>ty_rev_tab.
ENDCLASS.

CLASS zcl_rev_app IMPLEMENTATION.

  METHOD check_auth.
    " Minimalbeispiel: Transaktionsberechtigung prüfen (optional anpassbar)
    AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD sy-tcode.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_rev_app(
        textid = zcx_rev_app=>c_id_auth
        msg    = |Keine Berechtigung für Transaktion { sy-tcode }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD display_alv.
    DATA lo_alv TYPE REF TO cl_salv_table.
    DATA lt     TYPE zif_rev_repo=>ty_rev_tab.
    lt = it_data.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table      = lt ).
      CATCH cx_salv_msg INTO DATA(lx_salv).
        MESSAGE lx_salv TYPE 'E'.
        RETURN.
    ENDTRY.

    DATA(lo_cols) = lo_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).

    DATA(lo_col) = lo_cols->get_column( 'CARRID' ).
    lo_col->set_short_text( 'Carrier' ).
    lo_col = lo_cols->get_column( 'CARRNAME' ).
    lo_col->set_short_text( 'Name' ).
    lo_col = lo_cols->get_column( 'CURRENCY' ).
    lo_col->set_short_text( 'Curr' ).
    lo_col = lo_cols->get_column( 'FLIGHTS' ).
    lo_col->set_short_text( 'Flights' ).
    lo_col = lo_cols->get_column( 'SEATS' ).
    lo_col->set_short_text( 'Seats' ).
    lo_col = lo_cols->get_column( 'REVENUE' ).
    lo_col->set_short_text( 'Revenue' ).

    lo_alv->get_functions( )->set_all( abap_true ).
    lo_alv->display( ).
  ENDMETHOD.

  METHOD run.
    check_auth( ).

    DATA(lo_repo) = NEW zcl_rev_repo_dbtab( ).
    DATA(lo_srv)  = NEW zcl_rev_service( io_repo = lo_repo ).

    DATA lt_curr TYPE RANGE OF sflight-currency.
    IF so_curr[] IS NOT INITIAL. "globale Selektion aus Report
      lt_curr = so_curr[].
    ENDIF.

    DATA(lt_out) = lo_srv->run(
      i_date_from = p_from
      i_date_to   = p_to
      i_carrid    = p_carr
      it_curr     = lt_curr
      i_min_rev   = p_min
      i_sort      = COND abap_bool( WHEN p_sort = 'X' THEN abap_true ELSE abap_false )
      i_desc      = COND abap_bool( WHEN p_desc = 'X' THEN abap_true ELSE abap_false ) ).

    display_alv( lt_out ).
  ENDMETHOD.

ENDCLASS.
