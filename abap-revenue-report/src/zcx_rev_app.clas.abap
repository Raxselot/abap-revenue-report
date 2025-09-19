"! Fachliche Ausnahme (Static Check) mit einfachen Text-IDs
CLASS zcx_rev_app DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      c_id_invalid_input TYPE string VALUE 'INVALID_INPUT',
      c_id_no_data       TYPE string VALUE 'NO_DATA',
      c_id_auth          TYPE string VALUE 'AUTH'.
    METHODS constructor
      IMPORTING
        !textid   TYPE string
        !msg      TYPE string OPTIONAL
        !previous TYPE REF TO cx_root OPTIONAL.
ENDCLASS.

CLASS zcx_rev_app IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = previous ).
    " Einfache T100-neutrale Messageübergabe
    me->if_message~msgid = '00'.
    me->if_message~msgno = '398'.
    me->if_message~msgv1 = msg.
    me->if_t100_message~t100key-msgid = '00'.
    me->if_t100_message~t100key-msgno = '398'.
    me->if_t100_message~t100key-attr1 = 'MESSAGE'.
  ENDMETHOD.
ENDCLASS.
