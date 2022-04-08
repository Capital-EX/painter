! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors formatting kernel models
models.arrow models.product models.range painter.ui.theming
painter.utils sequences ui.gadgets ui.pens.solid ;
IN: painter.ui.color-preview

TUPLE: color-preview < gadget ;

M: color-preview model-changed
    swap value>> >>interior relayout-1 ;

: <color-fill> ( rgb -- solid )
    normalize-rgb first3 1 <rgba> <solid> ;

: rgb>string ( r g b -- string )
    "RGB -- %02X%02X%02X" sprintf ;

: <rgb-model> ( r-range g-range b-range -- product )
    [ range-model ] tri@ 3array <product> ;

: <color-preview-model> ( r-range g-range b-range -- arrow )
    <rgb-model> [ <color-fill> ] <arrow> ;

: <color-string-model> ( r-range g-range b-range -- model )
    <rgb-model> [ first3 rgb>string ] <arrow> ;

: <color-preview> ( r-range g-range b-range -- color-preview )
    color-preview new 
        [ <color-preview-model> ] dip swap >>model
        { 256 100 } >>dim 
        solid-black-border! ;