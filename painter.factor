! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays bresenham bresenham-cat byte-vectors
combinators combinators.smart continuations file-picker
formatting images images.loader images.viewer io io.pathnames
kernel math math.functions math.order math.parser models
models.range namespaces prettyprint sequences sequences.deep ui
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders
ui.gadgets.tracks ui.gestures ui.tools.listener vocabs.loader ;
FROM: models => change-model ;
IN: painter

<PRIVATE

SYMBOL: painter
SYMBOL: image-bounds

: color-range ( -- range )
    0 1 0 255 1 <range> ; inline

: brush-range ( -- range )
    1 1 1 20 1 <range> ;

: clamp-pos ( xy -- xy' )
     image-bounds get-global [ 0 swap clamp ] 2map ;

: get-image-pos ( painting-gadget -- xy )
    hand-rel clamp-pos ;

: make-image ( -- image )
    <image> { 256 256 } >>dim RGB >>component-order
        ubyte-components >>component-type
        256 256 3 * * 0 <array> >byte-vector >>bitmap ;

: get-range-value ( range-model -- fixnum )
    value>> first >fixnum ; inline

TUPLE: painting-gadget < image-control image-model r g b curr-xy old-xy brush-size ;
: <painting-gadget> ( -- gadget )
    painting-gadget new
        { 256 256 } >>dim 
        { 0 0 }     >>curr-xy 
        { 0 0 }     >>old-xy
        color-range >>r 
        color-range >>g 
        color-range >>b
        brush-range >>brush-size
    make-image <model> [ >>image-model ] keep set-image ;

: get-rgb ( painting-gadget -- rgb )
     [ 
        [ r>> get-range-value ] 
        [ g>> get-range-value ] 
        [ b>> get-range-value ] tri 
    ] output>array ;

: square-start-point ( x -- x' )
     2 / ceiling 1 - >fixnum ;

: get-points ( seq start-point -- points )
    '[ _ - ] map dup cartesian-product flatten1 ;

: square ( n -- points )
    [ <iota> ] [ square-start-point ] bi get-points ;

:: (stroke) ( image rgb points -- ) 
    points [ clamp-pos [ rgb ] dip first2 image set-pixel-at ] each ;

: stroke ( gadget offset -- )
    {
        [ drop image-model>> ]
        [ drop get-rgb ]
        [ [ curr-xy>> ] dip [ + ] 2map ]
        [ [  old-xy>> ] dip [ + ] 2map ] 
    } 2cleave bresenham [ (stroke) ] 2curry [ keep ] curry change-model ;

: place-pen ( gadget -- gadget )
    dup dup get-image-pos [ >>curr-xy drop ] [ >>old-xy drop ] 2bi ;

: place-pixel ( rgb x y image-model -- )
    [ [ set-pixel-at ] keep ] change-model ;

: update-pixel ( gadget -- )
    [ get-rgb ] 
    [ get-image-pos first2 ] 
    [ image-model>> ] tri place-pixel ;

: move-pen ( gadget -- gadget )
    dup [ curr-xy>> ] [ get-image-pos ] bi [ >>old-xy ] dip >>curr-xy  ;

: get-brush-size ( gadget -- gadget brush-size )
    dup brush-size>> get-range-value ;

: prepare-stroke-n ( points -- draw-calls )
    [ '[ _ stroke ] ] map ;

: (stroke-n)  ( gadget draw-calls -- )
    [ dupd call( gadget -- ) ] each drop ;

: pick-save-file ( -- path/f )
    home save-file-dialog ;


: popup-save-failed-message ( path -- )
    '[ 
        "Unknow file type!" 
         _ "File \"%s\" could not be saved as it's type is unrecognized." sprintf
         system-alert 
    ] call ;

: popup-save-success-message ( path -- )
    '[
        "File Saved!"
        _ "File \"%s\" was sucessfully saved!" sprintf
        system-alert
    ] call ;

: (?save-graphic-image) ( image path? -- )
    dup [ [ save-graphic-image ] [ popup-save-success-message ] bi ] [ drop drop ] if ;

: ?save-graphic-image ( image path? -- )
    [ (?save-graphic-image) ] [ [ popup-save-failed-message ] dip 2drop ] recover ;

PRIVATE>

: stroke-n ( gadget n -- )
    square prepare-stroke-n (stroke-n) ;

: pen-down ( gadget -- )
    place-pen update-pixel ;

: paint ( gadget -- )
    move-pen get-brush-size stroke-n  ;

: save-painting ( gadget -- )
    image-model>> value>> pick-save-file ?save-graphic-image ;

painting-gadget H{ 
    { T{ button-down } [ pen-down ] }
    { T{ drag }        [ paint ] }
} set-gestures

: build-sidebar ( painting-gadget -- sidebar )
    [ { 
        [ "Red"        <label> swap          r>> horizontal <slider> ]
        [ "Green"      <label> swap          g>> horizontal <slider> ]
        [ "Blue"       <label> swap          b>> horizontal <slider> ] 
        [ "Brush Size" <label> swap brush-size>> horizontal <slider> ]
        [ [ "Save" nip ] [ '[ drop _ save-painting  ]  ] bi <roll-button> ]
      } cleave
    ] output>array <pile> [ add-gadget ] reduce { 10 10 } <border> ;

: run-painter ( -- )
    { 255 255 } image-bounds set-global
    <painting-gadget> painter set-global
    [
        painter get-global
        [ 
            [ build-sidebar ] [ { 10 10 } <border> ] bi
        ] output>array <shelf> [ add-gadget ] reduce
        { 0 0 } <border> "Painter" open-window
    ] with-ui ; 

MAIN: run-painter 