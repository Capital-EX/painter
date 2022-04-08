! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays bresenham byte-vectors colors
combinators combinators.smart continuations file-picker
formatting images images.loader images.viewer io.pathnames
kernel math math.functions math.order models models.arrow
models.product models.range namespaces sequences sequences.deep
ui ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.sliders ui.gadgets.tracks
ui.gestures ui.pens.solid ;
FROM: models => change-model ;
IN: painter

<PRIVATE

SYMBOL: painter
SYMBOL: bounds { 512 512 } bounds set-global

: get-painter ( -- painter )
    painter get-global ; inline

: get-bounds ( -- bounds )
    bounds get-global ;

: normalize-rgb ( rgb -- rgb' )
    [ 255 /f ] map ;

: color-range ( -- range )
    0 1 0 256 1 <range> ;

: brush-range ( -- range )
    1 1 1 21 1 <range> ;

: clamp-pos ( xy -- xy' )
     get-bounds [ 1 - ] map [ 0 swap clamp ] 2map ;

: get-image-pos ( painting-gadget -- xy )
    hand-rel clamp-pos ;

: create-bitmap ( -- bitmap )
    get-bounds first2 3 * * 0 <array> >byte-vector ;

: make-image ( -- image )
    <image> 
        get-bounds       >>dim 
        RGB              >>component-order
        ubyte-components >>component-type
        create-bitmap    >>bitmap ;

: get-range-value ( range-model -- fixnum )
    value>> first >fixnum ;

: <range-label> ( range str -- label-control )
    [ range-model ] [ '[ _ sprintf ] <arrow> <label-control> ] bi* ;

: <labeled-slider> ( range str -- label-control slider )
    '[ _ <range-label> ] [ horizontal <slider> 1 >>line ] bi ;

: alert-failed ( path -- )
    '[ 
        "Unknow file type!" 
         _ "File \"%s\" could not be saved as it's type is unrecognized." sprintf
         system-alert 
    ] call ;

: alert-success ( path -- )
    '[
        "File Saved!"
        _ "File \"%s\" was sucessfully saved!" sprintf
        system-alert
    ] call ;

TUPLE: painting-gadget < image-control image-model r g b rgb curr-xy old-xy brush-size ;
: <painting-gadget> ( -- gadget )
    painting-gadget new
        { 0 0 }     >>curr-xy 
        { 0 0 }     >>old-xy
        color-range >>r
        color-range >>g
        color-range >>b
        brush-range >>brush-size
    make-image <model> [ >>image-model ] keep set-image ;

: get-rgb-ranges ( painter -- r-range b-range g-range ) 
    [ r>> ] [ g>> ] [ b>> ] tri ;

TUPLE: color-preview < gadget ;
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
        "black" named-color <solid> >>boundary ;

M: color-preview model-changed
    swap value>> >>interior relayout-1 ;

: get-rgb ( painting-gadget -- rgb )
    [ get-rgb-ranges [ get-range-value ] tri@ ] output>array ;

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
        [ [ curr-xy>> ] [ [ + ] 2map ] bi* ]
        [ [  old-xy>> ] [ [ + ] 2map ] bi* ] 
    } 2cleave bresenham '[ [ _ _ (stroke) ] keep ] change-model ;

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

: (?save-file) ( image path? -- )
    dup [ [ save-graphic-image ] [ alert-success ] bi ] [ 2drop ] if ;

: ?save-file ( image path? -- )
    [ (?save-file) ] [ [ alert-failed ] dip 2drop ] recover ;

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

: save-file ( gadget -- )
    image-model>> value>> pick-save-file ?save-file ;

: <save-button> ( gadget -- save-button )
    [ "Save" <label> { 5 5 } <border> nip ] [ '[ drop _ save-file ] ] bi <roll-button> ;

: <sidebar> ( -- sidebar )
    get-painter [ 
        { 
            [ r>> "Red: %02x" <labeled-slider> ]
            [ g>> "Green: %02x" <labeled-slider> ]
            [ b>> "Blue: %02x" <labeled-slider> ] 
            [ brush-size>> "Brush Size: %d" <labeled-slider> ]
            [ <save-button> { 5 5 } <border> { 1 1 } >>fill ]
            [ get-rgb-ranges <color-preview> { 0 0 } <border>  ]
            [ get-rgb-ranges <color-string-model> <label-control> { 0 0 } <border> ]
        } cleave
    ] output>array vertical <track> [ f track-add ] reduce { 0 0 } <border> { 1 0 } >>fill ;

: add-sidebar ( sidebar track -- track )
    swap 1 track-add ;

: add-painter ( painter-gadget track -- track ) 
    swap f track-add { 10 10 } >>gap ;

: pad ( gadget -- gadget )
    { 10 10 } <filled-border> { 800 0 } >>min-dim ;

: make-layout ( painting-gadget -- track )
    <sidebar> horizontal <track> add-sidebar add-painter pad ;

PRIVATE>

: run-painter ( -- )
    <painting-gadget> [ painter set-global ] keep 
    '[ _ make-layout "Painter" open-window ] with-ui ;

MAIN: run-painter 