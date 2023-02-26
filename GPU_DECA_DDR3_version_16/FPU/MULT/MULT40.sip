set_global_assignment -entity "MULT40" -library "lib_MULT40" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "MULT40" -library "lib_MULT40" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "MULT40" -library "lib_MULT40" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_MULT40" -name SPD_FILE [file join $::quartus(sip_path) "MULT40.spd"]

set_global_assignment -library "lib_MULT40" -name MISC_FILE [file join $::quartus(sip_path) "MULT40_sim/MULT40.vo"]
