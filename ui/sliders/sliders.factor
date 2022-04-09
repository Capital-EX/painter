! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors formatting kernel math models.arrow
models.range sequences ui.gadgets ui.gadgets.labels
ui.gadgets.sliders ;
IN: painter.ui.sliders

: get-range-value ( range-model -- fixnum )
    value>> first >fixnum ;

: <color-range> ( -- range )
    0 1 0 256 1 <range> ;

: <brush-range> ( -- range )
    1 1 1 21 1 <range> ;

: <range-label> ( range str -- label-control )
    [ range-model ] [ '[ _ sprintf ] <arrow> <label-control> ] bi* ;

: <labeled-slider> ( range str -- label-control slider )
    '[ _ <range-label> ] [ horizontal <slider> 1 >>line ] bi ;