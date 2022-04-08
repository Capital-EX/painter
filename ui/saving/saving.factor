! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations file-picker formatting
images.loader io.pathnames kernel ui ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.labels ;
IN: painter.ui.saving

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

: pick-save-file ( -- path/f )
    home save-file-dialog ;

: (?save-file) ( image path? -- )
    dup [ [ save-graphic-image ] [ alert-success ] bi ] [ 2drop ] if ;

: ?save-file ( image path? -- )
    [ (?save-file) ] [ [ alert-failed ] dip 2drop ] recover ;

: save-file ( gadget -- )
    value>> pick-save-file ?save-file ;

: <save-button> ( image-model -- save-button )
    [ "Save" <label> { 5 5 } <border> nip ] [ '[ drop _ save-file ] ] bi <roll-button> ;