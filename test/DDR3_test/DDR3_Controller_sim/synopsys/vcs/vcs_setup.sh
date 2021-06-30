
# (C) 2001-2021 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 20.1 720 win32 2021.01.09.11:27:10

# ----------------------------------------
# vcs - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     DDR3_Controller
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level shell script that compiles Altera simulation libraries
# and the Quartus-generated IP in your project, along with your design and
# testbench files, follow the guidelines below.
# 
# 1) Copy the shell script text from the TOP-LEVEL TEMPLATE section
# below into a new file, e.g. named "vcs_sim.sh".
# 
# 2) Copy the text from the DESIGN FILE LIST & OPTIONS TEMPLATE section into
# a separate file, e.g. named "filelist.f".
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # TOP_LEVEL_NAME is used in the Quartus-generated IP simulation script to
# # set the top-level simulation or testbench module/entity name.
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# # Source the Quartus-generated IP simulation script and do the following:
# # - Compile the Quartus EDA simulation library and IP simulation files.
# # - Specify TOP_LEVEL_NAME and QSYS_SIMDIR.
# # - Compile the design and top-level simulation module/entity using
# #   information specified in "filelist.f".
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# # - Run the simulation.
# #
# source <script generation output directory>/synopsys/vcs/vcs_setup.sh \
# TOP_LEVEL_NAME=<simulation top> \
# QSYS_SIMDIR=<script generation output directory> \
# USER_DEFINED_ELAB_OPTIONS="\"-f filelist.f\"" \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# ----------------------------------------
# # DESIGN FILE LIST & OPTIONS TEMPLATE - BEGIN
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the Quartus-generated IP simulation script)
# #
# +systemverilogext+.sv
# <design and testbench files, compile-time options, elaboration options>
# #
# # DESIGN FILE LIST & OPTIONS TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If DDR3_Controller is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Altera IP
# within the Quartus project, and generate a unified
# script which supports all the Altera IP within the design.
# ----------------------------------------
# ACDS 20.1 720 win32 2021.01.09.11:27:10
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="DDR3_Controller"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="G:/altera/20.1/quartus/"
SKIP_FILE_COPY=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"
# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_AC_ROM.hex ./
  cp -f $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_inst_ROM.hex ./
  cp -f $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_sequencer_mem.hex ./
fi

vcs -lca -timescale=1ps/1ps -sverilog +verilog2001ext+.v -ntb_opts dtm $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v \
  $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_hmi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_hssi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_hssi_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/cyclonev_pcie_hip_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_pcie_hip_atoms.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_slave_translator.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_master_translator.sv \
  $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_mm_st_converter.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_addr_cmd.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_addr_cmd_wrap.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ddr2_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ddr3_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_lpddr2_addr_cmd.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_rdwr_data_tmg.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_arbiter.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_burst_gen.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_cmd_gen.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_csr.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_buffer.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_buffer_manager.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_burst_tracking.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_dataid_manager.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_fifo.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_list.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_rdata_path.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_wdata_path.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_decoder.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_decoder_32_syn.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_decoder_64_syn.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_encoder.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_encoder_32_syn.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_encoder_64_syn.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_axi_st_converter.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_input_if.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_rank_timer.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_sideband.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_tbp.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_timing_param.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_controller.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_ddrx_controller_st_top.v \
  \"+incdir+$QSYS_SIMDIR/DDR3_Controller/\" $QSYS_SIMDIR/DDR3_Controller/alt_mem_if_nextgen_ddr3_controller_core.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_reset_controller.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_reset_synchronizer.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_dmaster_p2b_adapter.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_dmaster_b2p_adapter.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_packets_to_master.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_packets_to_bytes.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_bytes_to_packets.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_sc_fifo.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_dmaster_timing_adt.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_jtag_interface.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_jtag_dc_streaming.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_jtag_sld_node.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_jtag_streaming.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_clock_crosser.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_std_synchronizer_nocut.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_pipeline_base.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_idle_remover.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_idle_inserter.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_st_pipeline_stage.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_mm_interconnect_0.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_dll_cyclonev.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_oct_cyclonev.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_c0.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_dmaster.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_avalon_mm_bridge.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst_test_bench.v \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_sequencer_mem_no_ifdef_params.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_mem_if_sequencer_rst.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_arbitrator.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_burst_uncompressor.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_master_agent.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_reorder_memory.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_slave_agent.sv \
  $QSYS_SIMDIR/DDR3_Controller/altera_merlin_traffic_limiter.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_irq_mapper.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_avalon_st_adapter.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_demux.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_demux_001.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_demux_002.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_mux.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_mux_003.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_cmd_mux_005.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router_001.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router_002.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router_003.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router_006.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_router_008.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_rsp_demux_003.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_rsp_demux_005.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_rsp_mux.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_rsp_mux_001.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_s0_mm_interconnect_0_rsp_mux_002.sv \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_ac_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_ac_ROM_reg.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_bitcheck.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_core.sv \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_datamux.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_data_broadcast.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_data_decoder.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_ddr3.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_di_buffer.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_di_buffer_wrap.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_dm_decoder.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_generic.sv \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_inst_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_inst_ROM_reg.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_jumplogic.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_lfsr12.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_lfsr36.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_lfsr72.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_pattern_fifo.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_ram.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_ram_csr.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_read_datapath.v \
  $QSYS_SIMDIR/DDR3_Controller/rw_manager_write_decoder.v \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_data_mgr.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_phy_mgr.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_reg_file.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_acv_phase_decode.v \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_acv_wrapper.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_mgr.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_reg_file.v \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_siii_phase_decode.v \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_siii_wrapper.sv \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_sv_phase_decode.v \
  $QSYS_SIMDIR/DDR3_Controller/sequencer_scc_sv_wrapper.sv \
  $QSYS_SIMDIR/DDR3_Controller/afi_mux_ddr3_ddrx.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_clock_pair_generator.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_read_valid_selector.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_addr_cmd_datapath.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_reset.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_acv_ldc.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_memphy.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_reset_sync.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_new_io_pads.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_fr_cycle_shifter.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_fr_cycle_extender.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_read_datapath.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_write_datapath.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_core_shadow_registers.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_simple_ddio_out.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_phy_csr.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_iss_probe.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_addr_cmd_pads.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_flop_mem.v \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_p0_altdqdqs.v \
  $QSYS_SIMDIR/DDR3_Controller/altdq_dqs2_acv_cyclonev.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_pll0.sv \
  $QSYS_SIMDIR/DDR3_Controller/DDR3_Controller_0002.v \
  $QSYS_SIMDIR/DDR3_Controller.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
