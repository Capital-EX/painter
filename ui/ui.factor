! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.smart kernel namespaces
painter.ui.color-preview painter.ui.painting-gadget
painter.ui.saving painter.ui.sliders painter.ui.symbols
sequences ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.tracks ;
IN: painter.ui

: add-sidebar ( sidebar track -- track )
    swap 1 track-add ;

: add-painter ( painter-gadget track -- track ) 
    swap { 10 10 } <border> f track-add { 10 10 } >>gap ;

: pad ( gadget -- gadget )
    { 10 10 } <filled-border> { 800 0 } >>min-dim ;

: <layout> ( painting-gadget sidebar -- track )
     horizontal <track> add-sidebar add-painter pad ;

: <sidebar> ( -- sidebar )
    get-painter [ 
        { 
            [ r>> "Red: %02x" <labeled-slider> ]
            [ g>> "Green: %02x" <labeled-slider> ]
            [ b>> "Blue: %02x" <labeled-slider> ] 
            [ brush-size>> "Brush Size: %d" <labeled-slider> ]
            [ model>> <save-button> { 5 5 } <border> { 1 1 } >>fill ]
            [ get-rgb-ranges <color-preview> { 0 0 } <border>  ]
            [ get-rgb-ranges <color-string-model> <label-control> { 0 0 } <border> ]
        } cleave
    ] output>array vertical <track> [ f track-add ] reduce { 0 0 } <border> { 1 0 } >>fill ;

: <painter> ( -- gadget )
    <painting-gadget> [ painter set-global ] [ <sidebar> <layout> ] bi ;