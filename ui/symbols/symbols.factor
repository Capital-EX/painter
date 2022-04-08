! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces ;
IN: painter.ui.symbols

SYMBOL: painter
SYMBOL: bounds { 512 512 } bounds set-global

: get-painter ( -- painter )
    painter get-global ; inline

: get-bounds ( -- bounds )
    bounds get-global ;