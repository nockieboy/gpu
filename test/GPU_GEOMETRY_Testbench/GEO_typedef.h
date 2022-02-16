/*

Geometry unit's global typedef structures.

*/


typedef struct packed {              // Generate a structure for the sync generator bus.
                logic  [3:0] cmd    ; // command
                logic  [7:0] color  ; // 8 bit color
                logic  [3:0] depth  ; // pixel width
                logic  [3:0] bitpos ; // bit position for pixels less than 7 but wide.
                logic [31:0] addr   ;
                } pw_cmd_bus ;

