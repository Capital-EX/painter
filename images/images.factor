! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-vectors images kernel math
sequences ;
IN: painter.images

: <bitmap> ( dim -- bitmap )
    first2 3 * * 0 <array> >byte-vector ;

: <blank-image> ( dim -- image )
    <image> 
        over              >>dim 
        swap <bitmap>     >>bitmap
        RGB               >>component-order
        ubyte-components  >>component-type ;