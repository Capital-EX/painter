! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays byte-vectors combinators
combinators.smart images images.viewer io kernel math math.order
math.parser models models.range namespaces prettyprint sequences
ui ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.packs ui.gadgets.sliders ui.gadgets.tracks
ui.gestures ui.tools.listener vocabs.loader ;
FROM: models => change-model ;
IN: painter

TUPLE: painting-gadget < image-control image-model r g b ;

: make-image ( -- image )
    <image> { 256 256 } >>dim RGB >>component-order
        ubyte-components >>component-type
        256 256 3 * * 0 <array> >byte-vector >>bitmap ;

: color-range ( -- range )
    0 1 0 255 1 <range> ; inline

: <painting-gadget> ( -- gadget )
    painting-gadget new
    { 256 256 } >>dim 
    color-range >>r color-range >>g color-range >>b
    make-image <model> [ >>image-model ] keep set-image ;

: clamp-pos ( xy -- x' y' )
    [ first 0 255 clamp ] [ second 0 255 clamp ] bi ;

: get-image-pos ( painting-gadget -- x y )
    hand-rel clamp-pos ; inline

: get-range-value ( range-model -- fixnum )
    value>> first >fixnum ; inline

: get-rgb ( painting-gadget -- rgb )
     [ 
        [ r>> get-range-value ] 
        [ g>> get-range-value ] 
        [ b>> get-range-value ] tri 
    ] output>array ;

: update-pixel ( gadget -- )
    [ get-rgb ] 
    [ get-image-pos ] 
    [ image-model>> ] tri [ [ set-pixel-at ] keep ] change-model ;
`
painting-gadget H{ 
    { T{ button-down } [ update-pixel ] }
    { T{ drag } [ update-pixel ] }
} set-gestures

: build-sidebar ( painting-gadget -- sidebar )
    [ [ "Red"   <label> swap r>> horizontal <slider> ]
      [ "Green" <label> swap g>> horizontal <slider> ]
      [ "Blue"  <label> swap b>> horizontal <slider> ] tri
    ] output>array <pile> [ add-gadget ] reduce { 10 10 } <border> ;

: run-painter ( -- )
    [
        <painting-gadget> 
        [ 
            [ build-sidebar ] 
            [ { 10 10 } <border> ] bi 
        ] output>array 
        <shelf> [ add-gadget ] reduce { 0 0 } <border> 
        "Painter" open-window
    ] with-ui ;

MAIN: run-painter 