REPORT zrevenue_carrier_report
  LINE-SIZE 200
  NO STANDARD PAGE HEADING.

"-----------------------------
" Selection Screen 
"-----------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS:
  p_from TYPE sflight-fldate OBLIGATORY,
  p_to   TYPE sflight-fldate OBLIGATORY,
  p_carr TYPE s_carr_id DEFAULT ''.
SELECT-OPTIONS:
  so_curr FOR sflight-currency NO INTERVALS.
PARAMETERS:
  p_min  TYPE p DECIMALS 2 DEFAULT '0.00'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS:
  p_sort TYPE c AS CHECKBOX DEFAULT 'X',
  p_desc TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

"-----------------------------
" Top-Includes / Typen via Klassen
"-----------------------------
" (keine)

"-----------------------------
" Start
"-----------------------------
START-OF-SELECTION.
  TRY.
      NEW zcl_rev_app( )->run( ).
    CATCH zcx_rev_app INTO DATA(lx_app).
      MESSAGE lx_app->get_text( ) TYPE 'E'.
  ENDTRY.
