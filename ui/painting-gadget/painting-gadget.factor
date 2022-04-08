! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bresenham combinators combinators.smart images
images.viewer kernel math models painter.images
painter.ui.sliders painter.ui.symbols painter.ui.theming
painter.utils sequences ui.gestures ;
FROM: models => change-model ;
IN: painter.ui.painting-gadget

TUPLE: painting-gadget < image-control image-model r g b rgb curr-xy old-xy brush-size ;
: <painting-gadget> ( -- gadget )
    painting-gadget new
        { 0 0 }       >>curr-xy 
        { 0 0 }       >>old-xy
        <color-range> >>r
        <color-range> >>g
        <color-range> >>b
        <brush-range> >>brush-size
    get-bounds <blank-image> <model> [ >>image-model ] keep set-image
    solid-black-border! ;

: get-rgb-ranges ( painter -- r-range b-range g-range ) 
    [ r>> ] [ g>> ] [ b>> ] tri ;

: get-rgb ( painting-gadget -- rgb )
    [ get-rgb-ranges [ get-range-value ] tri@ ] output>array ;

: get-image-pos ( painting-gadget -- xy )
    hand-rel get-bounds clamp-pos ;

: place-pen ( gadget -- gadget )
    dup dup get-image-pos [ >>curr-xy drop ] [ >>old-xy drop ] 2bi ;

: (update-pixel) ( rgb x y image-model -- )
    [ [ set-pixel-at ] keep ] change-model ;

: update-pixel ( gadget -- )
    [ get-rgb ] 
    [ get-image-pos first2 ] 
    [ image-model>> ] tri (update-pixel) ;

: move-pen ( gadget -- gadget )
    dup [ curr-xy>> ] [ get-image-pos ] bi [ >>old-xy ] dip >>curr-xy  ;

: get-brush-size ( gadget -- gadget brush-size )
    dup brush-size>> get-range-value ;

:: (stroke) ( image rgb points -- ) 
    points [ get-bounds clamp-pos [ rgb ] dip first2 image set-pixel-at ] each ;

: stroke ( gadget offset -- )
    {
        [ drop image-model>> ]
        [ drop get-rgb ]
        [ [ curr-xy>> ] [ [ + ] 2map ] bi* ]
        [ [  old-xy>> ] [ [ + ] 2map ] bi* ] 
    } 2cleave bresenham '[ [ _ _ (stroke) ] keep ] change-model ;

: prepare-stroke-n ( points -- draw-calls )
    [ '[ _ stroke ] ] map ;

: (stroke-n)  ( gadget draw-calls -- )
    [ dupd call( gadget -- ) ] each drop ;

: stroke-n ( gadget n -- )
    square prepare-stroke-n (stroke-n) ;

: pen-down ( gadget -- )
    place-pen update-pixel ;

: paint ( gadget -- )
    move-pen get-brush-size stroke-n  ;

painting-gadget H{ 
    { T{ button-down } [ pen-down ] }
    { T{ drag } [ paint ] }
} set-gestures