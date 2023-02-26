set_global_assignment -entity "ADD40" -library "lib_ADD40" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "ADD40" -library "lib_ADD40" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "ADD40" -library "lib_ADD40" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ADD40" -name SPD_FILE [file join $::quartus(sip_path) "ADD40.spd"]

set_global_assignment -library "lib_ADD40" -name MISC_FILE [file join $::quartus(sip_path) "ADD40_sim/ADD40.vo"]
