! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bresenham combinators combinators.smart images
images.viewer kernel math math.vectors models painter.images
painter.ui.sliders painter.ui.symbols painter.ui.theming
painter.utils sequences ui.gestures ;
FROM: models => change-model ;
IN: painter.ui.painting-gadget

TUPLE: painting-gadget < image-control r g b rgb curr-xy old-xy brush-size ;
: <painting-gadget> ( -- gadget )
    painting-gadget new
        { 0 0 }       >>curr-xy 
        { 0 0 }       >>old-xy
        <color-range> >>r
        <color-range> >>g
        <color-range> >>b
        <brush-range> >>brush-size
    get-bounds <blank-image> <model> [ >>model ] keep set-image
    solid-black-border! ;

: get-brush-size ( gadget -- brush-size )
    brush-size>> get-range-value ;

: get-brush-area ( gadget -- brush-square )
    get-brush-size square ;

: get-rgb-ranges ( painter -- r-range b-range g-range ) 
    [ r>> ] [ g>> ] [ b>> ] tri ;

: get-rgb ( painting-gadget -- rgb )
    [ get-rgb-ranges [ get-range-value ] tri@ ] output>array ;

: get-image-pos ( painting-gadget -- xy )
    hand-rel get-bounds clamp-pos ;

: place-pen ( gadget -- )
    dup get-image-pos [ >>curr-xy drop ] [ >>old-xy drop ] 2bi ;

: update-image ( rgb x y image -- image )
    [ set-pixel-at ] keep ;

: (draw-pixel) ( rgb x y image-model -- )
    [ update-image ] change-model ;

: draw-pixel ( rgb image-model pixel -- )
    get-bounds clamp-pos swap [ first2 ] [ (draw-pixel) ] bi* ;

: draw-pixels ( rgb image-model offsets pixel -- )
   [ vs+ draw-pixel ] curry 2with each ;

: place-pixels ( gadget -- )
    {
        [ get-rgb ]
        [ model>> ]
        [ get-brush-area ]
        [ get-image-pos ]
    } cleave draw-pixels ;

: swap-curr-and-old ( gadget -- )
    dup curr-xy>> >>old-xy drop ;

: move-to-input ( gadget -- )
    dup get-image-pos >>curr-xy drop ;

: move-pen ( gadget -- )
    [ swap-curr-and-old ] [ move-to-input ] bi ;

: draw-stroke ( rgb image-model points -- )
    [ draw-pixel ] 2with each ;

: stroke ( gadget offset -- )
    {
        [ drop get-rgb ]
        [ drop model>> ]
        [ [ curr-xy>> ] [ vs+ ] bi* ]
        [ [  old-xy>> ] [ vs+ ] bi* ]
    } 2cleave bresenham draw-stroke ;

: prepare-stroke-n ( gadget -- draw-calls )
    get-brush-area [ '[ _ stroke ] ] map ;

: (stroke-n)  ( draw-calls gadget -- )
    swap [ call( gadget -- ) ] with each ;

: stroke-n ( gadget -- )
    [ prepare-stroke-n ] [ (stroke-n) ] bi ;

: pen-down ( gadget -- )
    [ place-pen ] [ place-pixels ] bi ;

: paint ( gadget -- )
    [ move-pen ] [ stroke-n ] bi ;

painting-gadget H{
    { T{ button-down } [ pen-down ] }
    { T{ drag } [ paint ] }
} set-gestures
