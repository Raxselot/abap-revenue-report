"! Service-Schicht: Validierung, Filter, Sortierung, Tests
CLASS zcl_rev_service DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: ty_tab TYPE zif_rev_repo=>ty_rev_tab.
    METHODS:
      constructor IMPORTING io_repo TYPE REF TO zif_rev_repo,
      run
        IMPORTING
          i_date_from TYPE sflight-fldate
          i_date_to   TYPE sflight-fldate
          i_carrid    TYPE s_carr_id OPTIONAL
          it_curr     TYPE RANGE OF sflight-currency OPTIONAL
          i_min_rev   TYPE p DECIMALS 2 DEFAULT '0.00'
          i_sort      TYPE abap_bool     DEFAULT abap_true
          i_desc      TYPE abap_bool     DEFAULT abap_true
        RETURNING VALUE(rt_data) TYPE ty_tab
        RAISING   zcx_rev_app.
  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO zif_rev_repo.
    METHODS validate_input
      IMPORTING i_date_from TYPE sflight-fldate
                i_date_to   TYPE sflight-fldate
      RAISING   zcx_rev_app.
ENDCLASS.

CLASS zcl_rev_service IMPLEMENTATION.

  METHOD constructor.
    ASSERT io_repo IS BOUND.
    mo_repo = io_repo.
  ENDMETHOD.

  METHOD validate_input.
    IF i_date_from IS INITIAL OR i_date_to IS INITIAL OR i_date_from > i_date_to.
      RAISE EXCEPTION NEW zcx_rev_app(
        textid = zcx_rev_app=>c_id_invalid_input
        msg    = |Ungültiger Datumsbereich: { i_date_from } – { i_date_to }| ).
    ENDIF.
  ENDMETHOD.

  METHOD run.
    validate_input( i_date_from = i_date_from i_date_to = i_date_to ).

    DATA(lt_data) = mo_repo->get_revenue(
        i_date_from = i_date_from
        i_date_to   = i_date_to
        i_carrid    = i_carrid
        it_curr     = it_curr ).

    IF lt_data IS INITIAL.
      RAISE EXCEPTION NEW zcx_rev_app(
        textid = zcx_rev_app=>c_id_no_data
        msg    = 'Keine Daten im Zeitraum/Filter gefunden.' ).
    ENDIF.

    IF i_min_rev > 0.
      DELETE lt_data WHERE revenue < i_min_rev.
      IF lt_data IS INITIAL.
        RAISE EXCEPTION NEW zcx_rev_app(
          textid = zcx_rev_app=>c_id_no_data
          msg    = |Alle Ergebnisse unter Mindestumsatz { i_min_rev }.| ).
      ENDIF.
    ENDIF.

    IF i_sort = abap_true.
      IF i_desc = abap_true.
        SORT lt_data BY revenue DESCENDING carrid ASCENDING currency ASCENDING.
      ELSE.
        SORT lt_data BY revenue ASCENDING carrid ASCENDING currency ASCENDING.
      ENDIF.
    ENDIF.

    rt_data = lt_data.
  ENDMETHOD.

ENDCLASS.

"-----------------------------
" ABAP Unit (Test Double DI)
"-----------------------------
CLASS ltc_service DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA go_srv TYPE REF TO zcl_rev_service.
    CLASS-METHODS class_setup.
    METHODS:
      test_validation FOR TESTING,
      test_filter_minrev FOR TESTING,
      test_sorting FOR TESTING.
ENDCLASS.

CLASS lcl_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_rev_repo.
    DATA mt_stub TYPE zif_rev_repo=>ty_rev_tab.
ENDCLASS.

CLASS lcl_repo_double IMPLEMENTATION.
  METHOD zif_rev_repo~get_revenue.
    rt_data = mt_stub.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_service IMPLEMENTATION.
  METHOD class_setup.
    DATA(lo_double) = NEW lcl_repo_double( ).
    lo_double->mt_stub = VALUE #(
      ( carrid = 'LH' carrname = 'Lufthansa'  currency = 'EUR' flights = 10 seats = 800 revenue = '120000.00' )
      ( carrid = 'AA' carrname = 'American'   currency = 'USD' flights =  5 seats = 350 revenue = '70000.00'  )
      ( carrid = 'BA' carrname = 'BritishAir' currency = 'GBP' flights =  2 seats = 120 revenue = '15000.00'  ) ).
    go_srv = NEW zcl_rev_service( io_repo = lo_double ).
  ENDMETHOD.

  METHOD test_validation.
    TRY.
        go_srv->run(
          i_date_from = '20250101'
          i_date_to   = '20241231' ). " from > to
        cl_abap_unit_assert=>fail( 'Expected exception for invalid dates' ).
      CATCH zcx_rev_app INTO DATA(lx).
        cl_abap_unit_assert=>assert_true( xsdbool( lx->get_text( ) CS 'Ungültiger Datumsbereich' ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_filter_minrev.
    DATA lt = go_srv->run(
      i_date_from = '20240101'
      i_date_to   = '20241231'
      i_min_rev   = '60000.00'
      i_sort      = abap_false
      i_desc      = abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt ) ).
    LOOP AT lt ASSIGNING FIELD-SYMBOL(<row>).
      cl_abap_unit_assert=>assert_true( <row>-revenue >= '60000.00' ).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_sorting.
    DATA lt = go_srv->run(
      i_date_from = '20240101'
      i_date_to   = '20241231'
      i_min_rev   = '0.00'
      i_sort      = abap_true
      i_desc      = abap_true ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt ) ).
    DATA(lv_prev) = CONV p( '9999999999.99' ).
    LOOP AT lt ASSIGNING FIELD-SYMBOL(<row>).
      cl_abap_unit_assert=>assert_true( <row>-revenue <= lv_prev ).
      lv_prev = <row>-revenue.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
