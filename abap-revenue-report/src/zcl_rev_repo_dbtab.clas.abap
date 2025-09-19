"! Konkretes Repository: liest SFLIGHT/SCARR und aggregiert Revenue
CLASS zcl_rev_repo_dbtab DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_rev_repo.
ENDCLASS.

CLASS zcl_rev_repo_dbtab IMPLEMENTATION.

  METHOD zif_rev_repo~get_revenue.
    DATA: lt_raw TYPE STANDARD TABLE OF sflight WITH EMPTY KEY,
          lt_out TYPE zif_rev_repo=>ty_rev_tab,
          ls_out TYPE zif_rev_repo=>ty_rev_row.

    SELECT * FROM sflight
      INTO TABLE @lt_raw
      WHERE fldate BETWEEN @i_date_from AND @i_date_to
        AND ( @i_carrid IS INITIAL OR carrid = @i_carrid )
        AND ( @it_curr  IS INITIAL OR currency IN @it_curr ).

    IF lt_raw IS INITIAL.
      RETURN.
    ENDIF.

    " SCARR join in-memory (Name)
    DATA lt_scarr TYPE SORTED TABLE OF scarr WITH UNIQUE KEY carrid.
    SELECT carrid, carrname FROM scarr
      INTO TABLE @lt_scarr
      FOR ALL ENTRIES IN @lt_raw
      WHERE carrid = @lt_raw-carrid.

    " Aggregation über Hash
    TYPES: BEGIN OF ty_key,
             carrid   TYPE s_carr_id,
             currency TYPE sflight-currency,
           END OF ty_key.
    TYPES: BEGIN OF ty_agg,
             key      TYPE ty_key,
             flights  TYPE i,
             seats    TYPE i,
             revenue  TYPE p DECIMALS 2,
           END OF ty_agg.
    DATA lt_map TYPE HASHED TABLE OF ty_agg WITH UNIQUE KEY key.
    DATA ls_map TYPE ty_agg.

    LOOP AT lt_raw ASSIGNING FIELD-SYMBOL(<r>).
      ls_map-key-carrid   = <r>-carrid.
      ls_map-key-currency = <r>-currency.
      READ TABLE lt_map WITH TABLE KEY key = ls_map-key ASSIGNING FIELD-SYMBOL(<agg>).
      IF sy-subrc <> 0.
        CLEAR ls_map.
        ls_map-key-carrid   = <r>-carrid.
        ls_map-key-currency = <r>-currency.
        INSERT ls_map INTO TABLE lt_map ASSIGNING <agg>.
      ENDIF.

      <agg>-flights  = <agg>-flights + 1.
      <agg>-seats    = <agg>-seats   + <r>-seatsocc.
      DATA(lv_rev)   = <r>-price * <r>-seatsocc. " Demo-Annahme: Preis je Sitz
      <agg>-revenue  = <agg>-revenue + lv_rev.
    ENDLOOP.

    LOOP AT lt_map ASSIGNING <agg>.
      CLEAR ls_out.
      ls_out-carrid   = <agg>-key-carrid.
      ls_out-currency = <agg>-key-currency.
      ls_out-flights  = <agg>-flights.
      ls_out-seats    = <agg>-seats.
      ls_out-revenue  = <agg>-revenue.

      READ TABLE lt_scarr WITH KEY carrid = ls_out-carrid INTO DATA(ls_scarr).
      IF sy-subrc = 0.
        ls_out-carrname = ls_scarr-carrname.
      ENDIF.
      APPEND ls_out TO lt_out.
    ENDLOOP.

    rt_data = lt_out.
  ENDMETHOD.

ENDCLASS.
