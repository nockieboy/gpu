set_global_assignment -entity "DIV40" -library "lib_DIV40" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "DIV40" -library "lib_DIV40" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "DIV40" -library "lib_DIV40" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_DIV40" -name SPD_FILE [file join $::quartus(sip_path) "DIV40.spd"]

set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC0_uid146_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC0_uid147_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC0_uid148_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC1_uid151_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC1_uid152_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC2_uid155_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC2_uid156_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40_memoryC3_uid159_invTables_lutmem.hex"]
set_global_assignment -library "lib_DIV40" -name MISC_FILE [file join $::quartus(sip_path) "DIV40_sim/DIV40.vo"]
