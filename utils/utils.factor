! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.order sequences
sequences.deep ;
IN: painter.utils

: normalize-rgb ( rgb -- rgb' )
    [ 255 /f ] map ;

: clamp-pos ( xy bounds -- xy' )
      [ 1 - ] map [ 0 swap clamp ] 2map ;

: square-start-point ( x -- x' )
     2 / ceiling 1 - >fixnum ;

: get-points ( seq start-point -- points )
    '[ _ - ] map dup cartesian-product flatten1 ;

: square ( n -- points )
    [ <iota> ] [ square-start-point ] bi get-points ;