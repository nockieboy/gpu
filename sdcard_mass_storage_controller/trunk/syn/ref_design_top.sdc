################################################################################
#  SDC WRITER VERSION "3.1";
#  DESIGN "ref_design_top";
#  Timing constraints scenario: "Primary";
#  DATE "Sun Mar 01 09:53:11 2009";
#  VENDOR "Actel";
#  PROGRAM "Actel Designer Software Release v8.5";
#  VERSION "8.5.0.34"  Copyright (C) 1989-2008 Actel Corp. 
################################################################################


set sdc_version 1.7


########  Clock Constraints  ########

create_clock  -name { clk_i } -period 40.000 -waveform { 0.000 20.000  }  { clk_pad_i  } 

create_clock  -name { tck } -period 83.333 -waveform { 0.000 41.667  }  { dbg_tck_pad_i  } 




########  Generated Clock Constraints  ########

create_generated_clock  -name { iclk_gen/Core:GLA } -divide_by 25  -multiply_by 25  -source { iclk_gen/Core:CLKA } { iclk_gen/Core:GLA  } 
#
# *** Note *** SmartTime supports extensions to the create_generated_clock constraint supported by SDC,
#              Extensions to this constraint may not be accepted by tools other than Actel's

create_generated_clock  -name { iclk_gen/Core:GLB } -divide_by 25  -multiply_by 48  -source { iclk_gen/Core:CLKA } { iclk_gen/Core:GLB  } 
#
# *** Note *** SmartTime supports extensions to the create_generated_clock constraint supported by SDC,
#              Extensions to this constraint may not be accepted by tools other than Actel's



########  Clock Source Latency Constraints #########



########  Input Delay Constraints  ########





########  Output Delay Constraints  ########

set_output_delay  -max 33.000 -clock { iclk_gen/Core:GLA }  [get_ports { mem_adr_pad_o mem_adr_pad_o[0] mem_adr_pad_o[10] mem_adr_pad_o[11] mem_adr_pad_o[12] mem_adr_pad_o[1] mem_adr_pad_o[2] mem_adr_pad_o[3] mem_adr_pad_o[4] mem_adr_pad_o[5] mem_adr_pad_o[6] mem_adr_pad_o[7] mem_adr_pad_o[8] mem_adr_pad_o[9] mem_ba_pad_o mem_ba_pad_o[0] mem_ba_pad_o[1] mem_cas_pad_o mem_cke_pad_o mem_cs_pad_o mem_dat_pad_io mem_dat_pad_io[0] mem_dat_pad_io[10] mem_dat_pad_io[11] mem_dat_pad_io[12] mem_dat_pad_io[13] mem_dat_pad_io[14] mem_dat_pad_io[15] mem_dat_pad_io[1] mem_dat_pad_io[2] mem_dat_pad_io[3] mem_dat_pad_io[4] mem_dat_pad_io[5] mem_dat_pad_io[6] mem_dat_pad_io[7] mem_dat_pad_io[8] mem_dat_pad_io[9] mem_dqm_pad_o mem_dqm_pad_o[0] mem_dqm_pad_o[1] mem_ras_pad_o mem_we_pad_o }] 

set_output_delay  -min -1.000 -clock { iclk_gen/Core:GLA }  [get_ports { mem_adr_pad_o mem_adr_pad_o[0] mem_adr_pad_o[10] mem_adr_pad_o[11] mem_adr_pad_o[12] mem_adr_pad_o[1] mem_adr_pad_o[2] mem_adr_pad_o[3] mem_adr_pad_o[4] mem_adr_pad_o[5] mem_adr_pad_o[6] mem_adr_pad_o[7] mem_adr_pad_o[8] mem_adr_pad_o[9] mem_ba_pad_o mem_ba_pad_o[0] mem_ba_pad_o[1] mem_cas_pad_o mem_cke_pad_o mem_cs_pad_o mem_dat_pad_io mem_dat_pad_io[0] mem_dat_pad_io[10] mem_dat_pad_io[11] mem_dat_pad_io[12] mem_dat_pad_io[13] mem_dat_pad_io[14] mem_dat_pad_io[15] mem_dat_pad_io[1] mem_dat_pad_io[2] mem_dat_pad_io[3] mem_dat_pad_io[4] mem_dat_pad_io[5] mem_dat_pad_io[6] mem_dat_pad_io[7] mem_dat_pad_io[8] mem_dat_pad_io[9] mem_dqm_pad_o mem_dqm_pad_o[0] mem_dqm_pad_o[1] mem_ras_pad_o mem_we_pad_o }] 





########   Delay Constraints  ########



########   Delay Constraints  ########



########   Multicycle Constraints  ########



########   False Path Constraints  ########



########   Output load Constraints  ########



########  Disable Timing Constraints #########



########  Clock Uncertainty Constraints #########

set_clock_uncertainty 0.4 -from { clk_i } -to { iclk_gen/Core:GLA iclk_gen/Core:GLB }
# PLL tracking jitter

set_clock_uncertainty 0.4 -from { iclk_gen/Core:GLA iclk_gen/Core:GLB } -to { clk_i }
# PLL tracking jitter



