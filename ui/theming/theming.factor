! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors ui.pens.solid ;
IN: painter.ui.theming

: solid-black-border! ( gadget -- gadget' )
    "black" named-color <solid> >>boundary ;