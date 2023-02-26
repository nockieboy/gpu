-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 20.1 (Release Build #720)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2020 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from ADD40_0002
-- VHDL created on Thu Oct 20 17:16:45 2022


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity ADD40_0002 is
    port (
        a : in std_logic_vector(39 downto 0);  -- float40_m31
        b : in std_logic_vector(39 downto 0);  -- float40_m31
        q : out std_logic_vector(39 downto 0);  -- float40_m31
        s : out std_logic_vector(39 downto 0);  -- float40_m31
        clk : in std_logic;
        areset : in std_logic
    );
end ADD40_0002;

architecture normal of ADD40_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracX_uid6_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (38 downto 0);
    signal expFracY_uid7_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (38 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (40 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (40 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (40 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal siga_uid9_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal siga_uid9_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal sigb_uid10_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal sigb_uid10_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal cstAllOWE_uid11_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid12_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal cstAllZWE_uid13_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_siga_uid14_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (38 downto 0);
    signal exp_siga_uid14_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_siga_uid15_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal frac_siga_uid15_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal excZ_siga_uid9_uid16_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_siga_uid9_uid16_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid17_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid17_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid18_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid18_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid19_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_siga_uid20_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_siga_uid21_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid22_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid23_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_siga_uid24_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal exp_sigb_uid28_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (38 downto 0);
    signal exp_sigb_uid28_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_sigb_uid29_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal frac_sigb_uid29_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal excZ_sigb_uid10_uid30_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_sigb_uid10_uid30_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid31_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid31_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid32_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid32_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid33_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_sigb_uid34_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_sigb_uid35_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid36_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid37_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_sigb_uid38_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_sigb_uid38_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigA_uid43_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sigB_uid44_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal effSub_uid45_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal cWFP1_uid49_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftOutConst_uid52_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal expAmExpBShiftRange_uid53_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (5 downto 0);
    signal expAmExpBShiftRange_uid53_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal shiftValue_uid54_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftValue_uid54_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal oFracB_uid56_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal oFracA_uid57_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal padConst_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (32 downto 0);
    signal rightPaddedIn_uid60_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal cmpStickyWZero_uid64_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal cmpStickyWZero_uid64_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sticky_uid65_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal alignFracB_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (34 downto 0);
    signal zv_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal fracAOp_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (34 downto 0);
    signal fracBOp_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (36 downto 0);
    signal fracResSub_uid71_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResSub_uid71_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResSub_uid71_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResSub_uid71_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResAdd_uid72_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResAdd_uid72_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResAdd_uid72_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResAdd_uid72_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (37 downto 0);
    signal fracResSubNoSignExt_uid73_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (35 downto 0);
    signal fracResSubNoSignExt_uid73_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (35 downto 0);
    signal fracResAddNoSignExt_uid74_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (35 downto 0);
    signal fracResAddNoSignExt_uid74_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (35 downto 0);
    signal cAmA_uid79_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal aMinusA_uid80_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal aMinusA_uid80_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expInc_uid81_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid81_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid81_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid81_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expPostNormSub_uid82_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid82_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid82_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid82_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid83_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid83_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid83_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid83_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fracPostNormSubRndRange_uid84_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (34 downto 0);
    signal fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal expFracRSub_uid85_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (41 downto 0);
    signal fracPostNormAddRndRange_uid86_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (34 downto 0);
    signal fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal expFracRAdd_uid87_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (41 downto 0);
    signal Sticky0_sub_uid88_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (0 downto 0);
    signal Sticky0_sub_uid88_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal Sticky1_sub_uid89_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (1 downto 0);
    signal Sticky1_sub_uid89_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal Round_sub_uid90_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (2 downto 0);
    signal Round_sub_uid90_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal Guard_sub_uid91_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (3 downto 0);
    signal Guard_sub_uid91_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal LSB_sub_uid92_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (4 downto 0);
    signal LSB_sub_uid92_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal rndBitCond_sub_uid93_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal cRBit_sub_uid94_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rBi_sub_uid95_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal rBi_sub_uid95_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal roundBit_sub_uid96_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracRSubPostRound_uid97_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRSubPostRound_uid97_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRSubPostRound_uid97_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRSubPostRound_uid97_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (42 downto 0);
    signal sticky0_add_uid98_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (0 downto 0);
    signal sticky0_add_uid98_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sticky1_add_uid99_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (1 downto 0);
    signal sticky1_add_uid99_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal Round_add_uid100_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (2 downto 0);
    signal Round_add_uid100_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal Guard_add_uid101_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (3 downto 0);
    signal Guard_add_uid101_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal LSB_add_uid102_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (4 downto 0);
    signal LSB_add_uid102_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal rndBitCond_add_uid103_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rBi_add_uid105_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal rBi_add_uid105_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal roundBit_add_uid106_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracRAddPostRound_uid107_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRAddPostRound_uid107_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRAddPostRound_uid107_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (42 downto 0);
    signal expFracRAddPostRound_uid107_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (42 downto 0);
    signal wEP2AllOwE_uid108_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal rndExp_uid109_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (41 downto 0);
    signal rndExp_uid109_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rOvf_uid110_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signedExp_uid111_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (41 downto 0);
    signal signedExp_uid111_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rUdf_uid112_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid112_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid112_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid112_fpFusedAddSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcSub_uid113_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExcSub_uid113_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPreExcSub_uid114_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (39 downto 0);
    signal expRPreExcSub_uid114_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracRPreExcAdd_uid116_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExcAdd_uid116_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPreExcAdd_uid117_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (39 downto 0);
    signal expRPreExcAdd_uid117_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal regInputs_uid119_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroVInC_uid120_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRZeroAdd_uid121_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroSub_uid122_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regInAndOvf_uid123_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal regInAndOvf_uid123_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsInf_uid124_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsInfOrZero_uid125_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsInfOrZero_uid125_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal addIsAlsoInf_uid126_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal addIsAlsoInf_uid126_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfVInC_uid127_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRInfAdd_uid128_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfAddFull_uid129_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfSub_uid130_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfSubFull_uid131_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal infMinf_uid132_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaNA_uid133_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invEffSub_uid134_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal infPinfForSub_uid135_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaNS_uid136_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExcSub_uid137_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal concExcAdd_uid138_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREncSub_uid139_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal excREncAdd_uid140_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPreExcAddition_uid141_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcAddition_uid141_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPreExcAddition_uid142_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExcAddition_uid142_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal fracRPreExcSubtraction_uid143_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPreExcSubtraction_uid144_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExcSubtraction_uid144_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal oneFracRPostExc2_uid145_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal fracRPostExcAdd_uid148_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExcAdd_uid148_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPostExcAdd_uid152_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExcAdd_uid152_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invXGTEy_uid153_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigA_uid154_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroSwap_uid155_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroSwap_uid156_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigB_uid157_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroNoSwap_uid158_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroNoSwap_uid159_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal aMa_uid160_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invAMA_uid161_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaNA_uid162_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid163_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid163_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal RSum_uid164_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal fracRPostExcSub_uid168_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExcSub_uid168_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPostExcSub_uid172_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExcSub_uid172_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal positiveExc_uid173_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invPositiveExc_uid174_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroForSub_uid175_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroForSub_uid176_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigY_uid177_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigY_uid178_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal yGTxYPos_uid180_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigX_uid181_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal xGTyXNeg_uid182_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub0_uid183_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub0_uid183_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaNS_uid184_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub_uid185_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub_uid185_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal RDiff_uid186_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal rVStage_uid190_lzCountValSub_uid75_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid192_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (3 downto 0);
    signal vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal cStage_uid194_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid222_lzCountValSub_uid75_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid223_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal rVStage_uid227_lzCountValAdd_uid77_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (3 downto 0);
    signal vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal cStage_uid231_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid259_lzCountValAdd_uid77_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid260_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal rightShiftStage0Idx1Rng8_uid265_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (56 downto 0);
    signal rightShiftStage0Idx1_uid267_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx2Rng16_uid268_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (48 downto 0);
    signal rightShiftStage0Idx2_uid270_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx3Rng24_uid271_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (40 downto 0);
    signal rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal rightShiftStage0Idx3_uid273_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx4Rng32_uid274_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal rightShiftStage0Idx4_uid276_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx5Rng40_uid277_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx5Pad40_uid278_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal rightShiftStage0Idx5_uid279_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx6Rng48_uid280_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (16 downto 0);
    signal rightShiftStage0Idx6Pad48_uid281_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (47 downto 0);
    signal rightShiftStage0Idx6_uid282_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0Idx7Rng56_uid283_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal rightShiftStage0Idx7Pad56_uid284_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (55 downto 0);
    signal rightShiftStage0Idx7_uid285_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx1Rng1_uid288_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (63 downto 0);
    signal rightShiftStage1Idx1_uid290_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx2Rng2_uid291_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (62 downto 0);
    signal rightShiftStage1Idx2_uid293_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx3Rng3_uid294_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (61 downto 0);
    signal rightShiftStage1Idx3_uid296_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx4Rng4_uid297_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (60 downto 0);
    signal rightShiftStage1Idx4_uid299_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx5Rng5_uid300_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (59 downto 0);
    signal rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rightShiftStage1Idx5_uid302_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx6Rng6_uid303_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (58 downto 0);
    signal rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal rightShiftStage1Idx6_uid305_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1Idx7Rng7_uid306_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (57 downto 0);
    signal rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (6 downto 0);
    signal rightShiftStage1Idx7_uid308_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (27 downto 0);
    signal leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal leftShiftStage0Idx1_uid316_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (19 downto 0);
    signal leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (19 downto 0);
    signal leftShiftStage0Idx2_uid319_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (11 downto 0);
    signal leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal leftShiftStage0Idx3_uid322_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx4_uid325_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (34 downto 0);
    signal leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (34 downto 0);
    signal leftShiftStage1Idx1_uid333_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (33 downto 0);
    signal leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (33 downto 0);
    signal leftShiftStage1Idx2_uid336_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage1Idx3_uid339_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal leftShiftStage1Idx4_uid342_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal leftShiftStage1Idx5_uid345_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage1Idx6_uid348_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (28 downto 0);
    signal leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (28 downto 0);
    signal leftShiftStage1Idx7_uid351_fracPostNormSub_uid76_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (27 downto 0);
    signal leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal leftShiftStage0Idx1_uid359_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (19 downto 0);
    signal leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (19 downto 0);
    signal leftShiftStage0Idx2_uid362_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (11 downto 0);
    signal leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal leftShiftStage0Idx3_uid365_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0Idx4_uid368_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (34 downto 0);
    signal leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (34 downto 0);
    signal leftShiftStage1Idx1_uid376_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (33 downto 0);
    signal leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (33 downto 0);
    signal leftShiftStage1Idx2_uid379_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal leftShiftStage1Idx3_uid382_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal leftShiftStage1Idx4_uid385_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal leftShiftStage1Idx5_uid388_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (29 downto 0);
    signal leftShiftStage1Idx6_uid391_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (28 downto 0);
    signal leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (28 downto 0);
    signal leftShiftStage1Idx7_uid394_fracPostNormAdd_uid78_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (64 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (64 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (35 downto 0);
    signal rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (2 downto 0);
    signal rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (2 downto 0);
    signal rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (2 downto 0);
    signal stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (30 downto 0);
    signal stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (33 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal redist0_stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (33 downto 0);
    signal redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist12_r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist13_vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist15_vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b_3_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist17_vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist19_vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist20_vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist21_vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist22_vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b_3_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist23_vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist24_signRPostExcSub_uid185_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist25_signRPostExcSub0_uid183_fpFusedAddSubTest_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist26_sigX_uid181_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist27_sigY_uid177_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist28_signRPostExc_uid163_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_invXGTEy_uid153_fpFusedAddSubTest_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist34_excRNaNS_uid136_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist35_excRNaNA_uid133_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_regInputs_uid119_fpFusedAddSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist37_fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist38_fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist39_aMinusA_uid80_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist45_effSub_uid45_fpFusedAddSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_effSub_uid45_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist47_sigB_uid44_fpFusedAddSubTest_b_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist48_sigA_uid43_fpFusedAddSubTest_b_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_InvExpXIsZero_uid37_fpFusedAddSubTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist58_excR_siga_uid24_fpFusedAddSubTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist59_excI_siga_uid20_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist63_frac_siga_uid15_fpFusedAddSubTest_b_4_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist64_exp_siga_uid14_fpFusedAddSubTest_b_10_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist65_xGTEy_uid8_fpFusedAddSubTest_n_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist66_xGTEy_uid8_fpFusedAddSubTest_n_12_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- expFracY_uid7_fpFusedAddSubTest(BITSELECT,6)@0
    expFracY_uid7_fpFusedAddSubTest_b <= b(38 downto 0);

    -- expFracX_uid6_fpFusedAddSubTest(BITSELECT,5)@0
    expFracX_uid6_fpFusedAddSubTest_b <= a(38 downto 0);

    -- xGTEy_uid8_fpFusedAddSubTest(COMPARE,7)@0
    xGTEy_uid8_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("00" & expFracX_uid6_fpFusedAddSubTest_b);
    xGTEy_uid8_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00" & expFracY_uid7_fpFusedAddSubTest_b);
    xGTEy_uid8_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(xGTEy_uid8_fpFusedAddSubTest_a) - UNSIGNED(xGTEy_uid8_fpFusedAddSubTest_b));
    xGTEy_uid8_fpFusedAddSubTest_n(0) <= not (xGTEy_uid8_fpFusedAddSubTest_o(40));

    -- sigb_uid10_fpFusedAddSubTest(MUX,9)@0
    sigb_uid10_fpFusedAddSubTest_s <= xGTEy_uid8_fpFusedAddSubTest_n;
    sigb_uid10_fpFusedAddSubTest_combproc: PROCESS (sigb_uid10_fpFusedAddSubTest_s, a, b)
    BEGIN
        CASE (sigb_uid10_fpFusedAddSubTest_s) IS
            WHEN "0" => sigb_uid10_fpFusedAddSubTest_q <= a;
            WHEN "1" => sigb_uid10_fpFusedAddSubTest_q <= b;
            WHEN OTHERS => sigb_uid10_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigB_uid44_fpFusedAddSubTest(BITSELECT,43)@0
    sigB_uid44_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(sigb_uid10_fpFusedAddSubTest_q(39 downto 39));

    -- redist47_sigB_uid44_fpFusedAddSubTest_b_12(DELAY,492)
    redist47_sigB_uid44_fpFusedAddSubTest_b_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 12, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigB_uid44_fpFusedAddSubTest_b, xout => redist47_sigB_uid44_fpFusedAddSubTest_b_12_q, clk => clk, aclr => areset );

    -- siga_uid9_fpFusedAddSubTest(MUX,8)@0 + 1
    siga_uid9_fpFusedAddSubTest_s <= xGTEy_uid8_fpFusedAddSubTest_n;
    siga_uid9_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            siga_uid9_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (siga_uid9_fpFusedAddSubTest_s) IS
                WHEN "0" => siga_uid9_fpFusedAddSubTest_q <= b;
                WHEN "1" => siga_uid9_fpFusedAddSubTest_q <= a;
                WHEN OTHERS => siga_uid9_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- sigA_uid43_fpFusedAddSubTest(BITSELECT,42)@1
    sigA_uid43_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(siga_uid9_fpFusedAddSubTest_q(39 downto 39));

    -- redist48_sigA_uid43_fpFusedAddSubTest_b_11(DELAY,493)
    redist48_sigA_uid43_fpFusedAddSubTest_b_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigA_uid43_fpFusedAddSubTest_b, xout => redist48_sigA_uid43_fpFusedAddSubTest_b_11_q, clk => clk, aclr => areset );

    -- cAmA_uid79_fpFusedAddSubTest(CONSTANT,78)
    cAmA_uid79_fpFusedAddSubTest_q <= "100100";

    -- zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest(CONSTANT,188)
    zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q <= "00000000000000000000000000000000";

    -- rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,306)
    rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest_q <= "0000000";

    -- rightShiftStage0Idx7Pad56_uid284_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,283)
    rightShiftStage0Idx7Pad56_uid284_alignmentShifter_uid59_fpFusedAddSubTest_q <= "00000000000000000000000000000000000000000000000000000000";

    -- cstAllZWE_uid13_fpFusedAddSubTest(CONSTANT,12)
    cstAllZWE_uid13_fpFusedAddSubTest_q <= "00000000";

    -- exp_sigb_uid28_fpFusedAddSubTest(BITSELECT,27)@0
    exp_sigb_uid28_fpFusedAddSubTest_in <= sigb_uid10_fpFusedAddSubTest_q(38 downto 0);
    exp_sigb_uid28_fpFusedAddSubTest_b <= exp_sigb_uid28_fpFusedAddSubTest_in(38 downto 31);

    -- redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1(DELAY,502)
    redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => exp_sigb_uid28_fpFusedAddSubTest_b, xout => redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- excZ_sigb_uid10_uid30_fpFusedAddSubTest(LOGICAL,29)@1 + 1
    excZ_sigb_uid10_uid30_fpFusedAddSubTest_qi <= "1" WHEN redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1_q = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";
    excZ_sigb_uid10_uid30_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_sigb_uid10_uid30_fpFusedAddSubTest_qi, xout => excZ_sigb_uid10_uid30_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid37_fpFusedAddSubTest(LOGICAL,36)@2
    InvExpXIsZero_uid37_fpFusedAddSubTest_q <= not (excZ_sigb_uid10_uid30_fpFusedAddSubTest_q);

    -- frac_sigb_uid29_fpFusedAddSubTest(BITSELECT,28)@0
    frac_sigb_uid29_fpFusedAddSubTest_in <= sigb_uid10_fpFusedAddSubTest_q(30 downto 0);
    frac_sigb_uid29_fpFusedAddSubTest_b <= frac_sigb_uid29_fpFusedAddSubTest_in(30 downto 0);

    -- redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2(DELAY,501)
    redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2 : dspba_delay
    GENERIC MAP ( width => 31, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => frac_sigb_uid29_fpFusedAddSubTest_b, xout => redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2_q, clk => clk, aclr => areset );

    -- oFracB_uid56_fpFusedAddSubTest(BITJOIN,55)@2
    oFracB_uid56_fpFusedAddSubTest_q <= InvExpXIsZero_uid37_fpFusedAddSubTest_q & redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2_q;

    -- padConst_uid59_fpFusedAddSubTest(CONSTANT,58)
    padConst_uid59_fpFusedAddSubTest_q <= "000000000000000000000000000000000";

    -- rightPaddedIn_uid60_fpFusedAddSubTest(BITJOIN,59)@2
    rightPaddedIn_uid60_fpFusedAddSubTest_q <= oFracB_uid56_fpFusedAddSubTest_q & padConst_uid59_fpFusedAddSubTest_q;

    -- rightShiftStage0Idx7Rng56_uid283_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,282)@2
    rightShiftStage0Idx7Rng56_uid283_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 56);

    -- rightShiftStage0Idx7_uid285_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,284)@2
    rightShiftStage0Idx7_uid285_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx7Pad56_uid284_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx7Rng56_uid283_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx6Pad48_uid281_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,280)
    rightShiftStage0Idx6Pad48_uid281_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000000000000000000000000000000000000000000000000";

    -- rightShiftStage0Idx6Rng48_uid280_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,279)@2
    rightShiftStage0Idx6Rng48_uid280_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 48);

    -- rightShiftStage0Idx6_uid282_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,281)@2
    rightShiftStage0Idx6_uid282_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx6Pad48_uid281_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx6Rng48_uid280_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx5Pad40_uid278_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,277)
    rightShiftStage0Idx5Pad40_uid278_alignmentShifter_uid59_fpFusedAddSubTest_q <= "0000000000000000000000000000000000000000";

    -- rightShiftStage0Idx5Rng40_uid277_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,276)@2
    rightShiftStage0Idx5Rng40_uid277_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 40);

    -- rightShiftStage0Idx5_uid279_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,278)@2
    rightShiftStage0Idx5_uid279_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx5Pad40_uid278_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx5Rng40_uid277_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx4Rng32_uid274_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,273)@2
    rightShiftStage0Idx4Rng32_uid274_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 32);

    -- rightShiftStage0Idx4_uid276_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,275)@2
    rightShiftStage0Idx4_uid276_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q & rightShiftStage0Idx4Rng32_uid274_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1(MUX,400)@2
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_combproc: PROCESS (rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s, rightShiftStage0Idx4_uid276_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx5_uid279_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx6_uid282_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx7_uid285_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx4_uid276_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "01" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx5_uid279_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx6_uid282_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx7_uid285_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,271)
    rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000000000000000000000000";

    -- rightShiftStage0Idx3Rng24_uid271_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,270)@2
    rightShiftStage0Idx3Rng24_uid271_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 24);

    -- rightShiftStage0Idx3_uid273_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,272)@2
    rightShiftStage0Idx3_uid273_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx3Rng24_uid271_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest(CONSTANT,196)
    zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q <= "0000000000000000";

    -- rightShiftStage0Idx2Rng16_uid268_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,267)@2
    rightShiftStage0Idx2Rng16_uid268_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 16);

    -- rightShiftStage0Idx2_uid270_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,269)@2
    rightShiftStage0Idx2_uid270_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q & rightShiftStage0Idx2Rng16_uid268_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx1Rng8_uid265_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,264)@2
    rightShiftStage0Idx1Rng8_uid265_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightPaddedIn_uid60_fpFusedAddSubTest_q(64 downto 8);

    -- rightShiftStage0Idx1_uid267_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,266)@2
    rightShiftStage0Idx1_uid267_alignmentShifter_uid59_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q & rightShiftStage0Idx1Rng8_uid265_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0(MUX,399)@2
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_combproc: PROCESS (rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s, rightPaddedIn_uid60_fpFusedAddSubTest_q, rightShiftStage0Idx1_uid267_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx2_uid270_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx3_uid273_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightPaddedIn_uid60_fpFusedAddSubTest_q;
            WHEN "01" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx1_uid267_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx2_uid270_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx3_uid273_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- shiftOutConst_uid52_fpFusedAddSubTest(CONSTANT,51)
    shiftOutConst_uid52_fpFusedAddSubTest_q <= "100001";

    -- exp_siga_uid14_fpFusedAddSubTest(BITSELECT,13)@1
    exp_siga_uid14_fpFusedAddSubTest_in <= siga_uid9_fpFusedAddSubTest_q(38 downto 0);
    exp_siga_uid14_fpFusedAddSubTest_b <= exp_siga_uid14_fpFusedAddSubTest_in(38 downto 31);

    -- expAmExpB_uid48_fpFusedAddSubTest(SUB,47)@1
    expAmExpB_uid48_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & exp_siga_uid14_fpFusedAddSubTest_b);
    expAmExpB_uid48_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1_q);
    expAmExpB_uid48_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expAmExpB_uid48_fpFusedAddSubTest_a) - UNSIGNED(expAmExpB_uid48_fpFusedAddSubTest_b));
    expAmExpB_uid48_fpFusedAddSubTest_q <= expAmExpB_uid48_fpFusedAddSubTest_o(8 downto 0);

    -- expAmExpBShiftRange_uid53_fpFusedAddSubTest(BITSELECT,52)@1
    expAmExpBShiftRange_uid53_fpFusedAddSubTest_in <= expAmExpB_uid48_fpFusedAddSubTest_q(5 downto 0);
    expAmExpBShiftRange_uid53_fpFusedAddSubTest_b <= expAmExpBShiftRange_uid53_fpFusedAddSubTest_in(5 downto 0);

    -- redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1(DELAY,489)
    redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 6, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expAmExpBShiftRange_uid53_fpFusedAddSubTest_b, xout => redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- cWFP1_uid49_fpFusedAddSubTest(CONSTANT,48)
    cWFP1_uid49_fpFusedAddSubTest_q <= "100000";

    -- shiftedOut_uid51_fpFusedAddSubTest(COMPARE,50)@1 + 1
    shiftedOut_uid51_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("00000" & cWFP1_uid49_fpFusedAddSubTest_q);
    shiftedOut_uid51_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00" & expAmExpB_uid48_fpFusedAddSubTest_q);
    shiftedOut_uid51_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            shiftedOut_uid51_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            shiftedOut_uid51_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(shiftedOut_uid51_fpFusedAddSubTest_a) - UNSIGNED(shiftedOut_uid51_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    shiftedOut_uid51_fpFusedAddSubTest_c(0) <= shiftedOut_uid51_fpFusedAddSubTest_o(10);

    -- shiftValue_uid54_fpFusedAddSubTest(MUX,53)@2
    shiftValue_uid54_fpFusedAddSubTest_s <= shiftedOut_uid51_fpFusedAddSubTest_c;
    shiftValue_uid54_fpFusedAddSubTest_combproc: PROCESS (shiftValue_uid54_fpFusedAddSubTest_s, redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1_q, shiftOutConst_uid52_fpFusedAddSubTest_q)
    BEGIN
        CASE (shiftValue_uid54_fpFusedAddSubTest_s) IS
            WHEN "0" => shiftValue_uid54_fpFusedAddSubTest_q <= redist44_expAmExpBShiftRange_uid53_fpFusedAddSubTest_b_1_q;
            WHEN "1" => shiftValue_uid54_fpFusedAddSubTest_q <= shiftOutConst_uid52_fpFusedAddSubTest_q;
            WHEN OTHERS => shiftValue_uid54_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select(BITSELECT,427)@2
    rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b <= shiftValue_uid54_fpFusedAddSubTest_q(5 downto 3);
    rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c <= shiftValue_uid54_fpFusedAddSubTest_q(2 downto 0);

    -- rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,439)@2
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal(MUX,401)@2 + 1
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rightShiftStage1Idx7Rng7_uid306_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,305)@3
    rightShiftStage1Idx7Rng7_uid306_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 7);

    -- rightShiftStage1Idx7_uid308_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,307)@3
    rightShiftStage1Idx7_uid308_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage1Idx7Rng7_uid306_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,303)
    rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000000";

    -- rightShiftStage1Idx6Rng6_uid303_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,302)@3
    rightShiftStage1Idx6Rng6_uid303_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 6);

    -- rightShiftStage1Idx6_uid305_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,304)@3
    rightShiftStage1Idx6_uid305_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage1Idx6Rng6_uid303_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,300)
    rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest_q <= "00000";

    -- rightShiftStage1Idx5Rng5_uid300_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,299)@3
    rightShiftStage1Idx5Rng5_uid300_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 5);

    -- rightShiftStage1Idx5_uid302_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,301)@3
    rightShiftStage1Idx5_uid302_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage1Idx5Rng5_uid300_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest(CONSTANT,208)
    zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q <= "0000";

    -- rightShiftStage1Idx4Rng4_uid297_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,296)@3
    rightShiftStage1Idx4Rng4_uid297_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 4);

    -- rightShiftStage1Idx4_uid299_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,298)@3
    rightShiftStage1Idx4_uid299_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q & rightShiftStage1Idx4Rng4_uid297_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1(MUX,405)@3
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_combproc: PROCESS (rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s, rightShiftStage1Idx4_uid299_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx5_uid302_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx6_uid305_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx7_uid308_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage1Idx4_uid299_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "01" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage1Idx5_uid302_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage1Idx6_uid305_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage1Idx7_uid308_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- zv_uid68_fpFusedAddSubTest(CONSTANT,67)
    zv_uid68_fpFusedAddSubTest_q <= "000";

    -- rightShiftStage1Idx3Rng3_uid294_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,293)@3
    rightShiftStage1Idx3Rng3_uid294_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 3);

    -- rightShiftStage1Idx3_uid296_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,295)@3
    rightShiftStage1Idx3_uid296_alignmentShifter_uid59_fpFusedAddSubTest_q <= zv_uid68_fpFusedAddSubTest_q & rightShiftStage1Idx3Rng3_uid294_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest(CONSTANT,214)
    zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q <= "00";

    -- rightShiftStage1Idx2Rng2_uid291_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,290)@3
    rightShiftStage1Idx2Rng2_uid291_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 2);

    -- rightShiftStage1Idx2_uid293_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,292)@3
    rightShiftStage1Idx2_uid293_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q & rightShiftStage1Idx2Rng2_uid291_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1Idx1Rng1_uid288_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,287)@3
    rightShiftStage1Idx1Rng1_uid288_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 1);

    -- rightShiftStage1Idx1_uid290_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,289)@3
    rightShiftStage1Idx1_uid290_alignmentShifter_uid59_fpFusedAddSubTest_q <= GND_q & rightShiftStage1Idx1Rng1_uid288_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0(MUX,404)@3
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_combproc: PROCESS (rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s, rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q, rightShiftStage1Idx1_uid290_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx2_uid293_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx3_uid296_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0_uid287_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage1Idx1_uid290_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage1Idx2_uid293_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage1Idx3_uid296_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,456)
    redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 3, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c, xout => redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,440)@3
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1_q(1 downto 0);
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= redist11_rightShiftStageSel5Dto3_uid286_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c_1_q(2 downto 2);

    -- rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal(MUX,406)@3 + 1
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- stickyBits_uid62_fpFusedAddSubTest_merged_bit_select(BITSELECT,438)@4
    stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_b <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(30 downto 0);
    stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c <= rightShiftStage1_uid310_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(64 downto 31);

    -- redist0_stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,445)
    redist0_stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 34, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c, xout => redist0_stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- cstZeroWF_uid12_fpFusedAddSubTest(CONSTANT,11)
    cstZeroWF_uid12_fpFusedAddSubTest_q <= "0000000000000000000000000000000";

    -- cmpStickyWZero_uid64_fpFusedAddSubTest(LOGICAL,63)@4 + 1
    cmpStickyWZero_uid64_fpFusedAddSubTest_qi <= "1" WHEN stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_b = cstZeroWF_uid12_fpFusedAddSubTest_q ELSE "0";
    cmpStickyWZero_uid64_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => cmpStickyWZero_uid64_fpFusedAddSubTest_qi, xout => cmpStickyWZero_uid64_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- sticky_uid65_fpFusedAddSubTest(LOGICAL,64)@5
    sticky_uid65_fpFusedAddSubTest_q <= not (cmpStickyWZero_uid64_fpFusedAddSubTest_q);

    -- alignFracB_uid67_fpFusedAddSubTest(BITJOIN,66)@5
    alignFracB_uid67_fpFusedAddSubTest_q <= redist0_stickyBits_uid62_fpFusedAddSubTest_merged_bit_select_c_1_q & sticky_uid65_fpFusedAddSubTest_q;

    -- fracBOp_uid70_fpFusedAddSubTest(BITJOIN,69)@5
    fracBOp_uid70_fpFusedAddSubTest_q <= GND_q & GND_q & alignFracB_uid67_fpFusedAddSubTest_q;

    -- frac_siga_uid15_fpFusedAddSubTest(BITSELECT,14)@1
    frac_siga_uid15_fpFusedAddSubTest_in <= siga_uid9_fpFusedAddSubTest_q(30 downto 0);
    frac_siga_uid15_fpFusedAddSubTest_b <= frac_siga_uid15_fpFusedAddSubTest_in(30 downto 0);

    -- redist63_frac_siga_uid15_fpFusedAddSubTest_b_4(DELAY,508)
    redist63_frac_siga_uid15_fpFusedAddSubTest_b_4 : dspba_delay
    GENERIC MAP ( width => 31, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => frac_siga_uid15_fpFusedAddSubTest_b, xout => redist63_frac_siga_uid15_fpFusedAddSubTest_b_4_q, clk => clk, aclr => areset );

    -- oFracA_uid57_fpFusedAddSubTest(BITJOIN,56)@5
    oFracA_uid57_fpFusedAddSubTest_q <= VCC_q & redist63_frac_siga_uid15_fpFusedAddSubTest_b_4_q;

    -- fracAOp_uid69_fpFusedAddSubTest(BITJOIN,68)@5
    fracAOp_uid69_fpFusedAddSubTest_q <= oFracA_uid57_fpFusedAddSubTest_q & zv_uid68_fpFusedAddSubTest_q;

    -- fracResSub_uid71_fpFusedAddSubTest(SUB,70)@5
    fracResSub_uid71_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("000" & fracAOp_uid69_fpFusedAddSubTest_q);
    fracResSub_uid71_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & fracBOp_uid70_fpFusedAddSubTest_q);
    fracResSub_uid71_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracResSub_uid71_fpFusedAddSubTest_a) - UNSIGNED(fracResSub_uid71_fpFusedAddSubTest_b));
    fracResSub_uid71_fpFusedAddSubTest_q <= fracResSub_uid71_fpFusedAddSubTest_o(37 downto 0);

    -- fracResSubNoSignExt_uid73_fpFusedAddSubTest(BITSELECT,72)@5
    fracResSubNoSignExt_uid73_fpFusedAddSubTest_in <= fracResSub_uid71_fpFusedAddSubTest_q(35 downto 0);
    fracResSubNoSignExt_uid73_fpFusedAddSubTest_b <= fracResSubNoSignExt_uid73_fpFusedAddSubTest_in(35 downto 0);

    -- redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1(DELAY,487)
    redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 36, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracResSubNoSignExt_uid73_fpFusedAddSubTest_b, xout => redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- rVStage_uid190_lzCountValSub_uid75_fpFusedAddSubTest(BITSELECT,189)@6
    rVStage_uid190_lzCountValSub_uid75_fpFusedAddSubTest_b <= redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1_q(35 downto 4);

    -- vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,190)@6
    vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid190_lzCountValSub_uid75_fpFusedAddSubTest_b = zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist23_vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q_3(DELAY,468)
    redist23_vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q, xout => redist23_vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest(BITSELECT,192)@6
    vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_in <= redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1_q(3 downto 0);
    vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b <= vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_in(3 downto 0);

    -- mO_uid192_lzCountValSub_uid75_fpFusedAddSubTest(CONSTANT,191)
    mO_uid192_lzCountValSub_uid75_fpFusedAddSubTest_q <= "1111111111111111111111111111";

    -- cStage_uid194_lzCountValSub_uid75_fpFusedAddSubTest(BITJOIN,193)@6
    cStage_uid194_lzCountValSub_uid75_fpFusedAddSubTest_q <= vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b & mO_uid192_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest(MUX,195)@6 + 1
    vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_s <= vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q;
    vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_s) IS
                WHEN "0" => vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q <= rVStage_uid190_lzCountValSub_uid75_fpFusedAddSubTest_b;
                WHEN "1" => vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q <= cStage_uid194_lzCountValSub_uid75_fpFusedAddSubTest_q;
                WHEN OTHERS => vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select(BITSELECT,428)@7
    rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q(31 downto 16);
    rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid196_lzCountValSub_uid75_fpFusedAddSubTest_q(15 downto 0);

    -- vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,198)@7
    vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b = zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist21_vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q_2(DELAY,466)
    redist21_vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q, xout => redist21_vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest(MUX,201)@7
    vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_s <= vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q;
    vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_s, rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q <= rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q <= rVStage_uid198_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select(BITSELECT,429)@7
    rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q(15 downto 8);
    rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid202_lzCountValSub_uid75_fpFusedAddSubTest_q(7 downto 0);

    -- vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,204)@7 + 1
    vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_qi <= "1" WHEN rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";
    vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_qi, xout => vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist20_vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q_2(DELAY,465)
    redist20_vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q, xout => redist20_vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,455)
    redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c, xout => redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1(DELAY,454)
    redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b, xout => redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest(MUX,207)@8
    vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_s <= vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q;
    vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_s, redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q, redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q <= redist9_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q <= redist10_rVStage_uid204_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select(BITSELECT,430)@8
    rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q(7 downto 4);
    rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid208_lzCountValSub_uid75_fpFusedAddSubTest_q(3 downto 0);

    -- vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,210)@8
    vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b = zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist19_vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q_1(DELAY,464)
    redist19_vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q, xout => redist19_vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q_1_q, clk => clk, aclr => areset );

    -- vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest(MUX,213)@8
    vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_s <= vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q;
    vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_s, rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q <= rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q <= rVStage_uid210_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select(BITSELECT,431)@8
    rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q(3 downto 2);
    rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid214_lzCountValSub_uid75_fpFusedAddSubTest_q(1 downto 0);

    -- vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,216)@8 + 1
    vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_qi <= "1" WHEN rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b = zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";
    vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_qi, xout => vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,453)
    redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c, xout => redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1(DELAY,452)
    redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b, xout => redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest(MUX,219)@9
    vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_s <= vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_q;
    vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_s, redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q, redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_q <= redist7_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_q <= redist8_rVStage_uid216_lzCountValSub_uid75_fpFusedAddSubTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid222_lzCountValSub_uid75_fpFusedAddSubTest(BITSELECT,221)@9
    rVStage_uid222_lzCountValSub_uid75_fpFusedAddSubTest_b <= vStagei_uid220_lzCountValSub_uid75_fpFusedAddSubTest_q(1 downto 1);

    -- vCount_uid223_lzCountValSub_uid75_fpFusedAddSubTest(LOGICAL,222)@9
    vCount_uid223_lzCountValSub_uid75_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid222_lzCountValSub_uid75_fpFusedAddSubTest_b = GND_q ELSE "0";

    -- r_uid224_lzCountValSub_uid75_fpFusedAddSubTest(BITJOIN,223)@9
    r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q <= redist23_vCount_uid191_lzCountValSub_uid75_fpFusedAddSubTest_q_3_q & redist21_vCount_uid199_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q & redist20_vCount_uid205_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q & redist19_vCount_uid211_lzCountValSub_uid75_fpFusedAddSubTest_q_1_q & vCount_uid217_lzCountValSub_uid75_fpFusedAddSubTest_q & vCount_uid223_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2(DELAY,463)
    redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 6, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q, xout => redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- aMinusA_uid80_fpFusedAddSubTest(LOGICAL,79)@11 + 1
    aMinusA_uid80_fpFusedAddSubTest_qi <= "1" WHEN redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q = cAmA_uid79_fpFusedAddSubTest_q ELSE "0";
    aMinusA_uid80_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => aMinusA_uid80_fpFusedAddSubTest_qi, xout => aMinusA_uid80_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid11_fpFusedAddSubTest(CONSTANT,10)
    cstAllOWE_uid11_fpFusedAddSubTest_q <= "11111111";

    -- redist64_exp_siga_uid14_fpFusedAddSubTest_b_10(DELAY,509)
    redist64_exp_siga_uid14_fpFusedAddSubTest_b_10 : dspba_delay
    GENERIC MAP ( width => 8, depth => 10, reset_kind => "ASYNC" )
    PORT MAP ( xin => exp_siga_uid14_fpFusedAddSubTest_b, xout => redist64_exp_siga_uid14_fpFusedAddSubTest_b_10_q, clk => clk, aclr => areset );

    -- expXIsMax_uid17_fpFusedAddSubTest(LOGICAL,16)@11 + 1
    expXIsMax_uid17_fpFusedAddSubTest_qi <= "1" WHEN redist64_exp_siga_uid14_fpFusedAddSubTest_b_10_q = cstAllOWE_uid11_fpFusedAddSubTest_q ELSE "0";
    expXIsMax_uid17_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid17_fpFusedAddSubTest_qi, xout => expXIsMax_uid17_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- invExpXIsMax_uid22_fpFusedAddSubTest(LOGICAL,21)@12
    invExpXIsMax_uid22_fpFusedAddSubTest_q <= not (expXIsMax_uid17_fpFusedAddSubTest_q);

    -- excZ_siga_uid9_uid16_fpFusedAddSubTest(LOGICAL,15)@11 + 1
    excZ_siga_uid9_uid16_fpFusedAddSubTest_qi <= "1" WHEN redist64_exp_siga_uid14_fpFusedAddSubTest_b_10_q = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";
    excZ_siga_uid9_uid16_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_siga_uid9_uid16_fpFusedAddSubTest_qi, xout => excZ_siga_uid9_uid16_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- InvExpXIsZero_uid23_fpFusedAddSubTest(LOGICAL,22)@12
    InvExpXIsZero_uid23_fpFusedAddSubTest_q <= not (excZ_siga_uid9_uid16_fpFusedAddSubTest_q);

    -- excR_siga_uid24_fpFusedAddSubTest(LOGICAL,23)@12
    excR_siga_uid24_fpFusedAddSubTest_q <= InvExpXIsZero_uid23_fpFusedAddSubTest_q and invExpXIsMax_uid22_fpFusedAddSubTest_q;

    -- positiveExc_uid173_fpFusedAddSubTest(LOGICAL,172)@12
    positiveExc_uid173_fpFusedAddSubTest_q <= excR_siga_uid24_fpFusedAddSubTest_q and aMinusA_uid80_fpFusedAddSubTest_q and redist48_sigA_uid43_fpFusedAddSubTest_b_11_q and redist47_sigB_uid44_fpFusedAddSubTest_b_12_q;

    -- invPositiveExc_uid174_fpFusedAddSubTest(LOGICAL,173)@12
    invPositiveExc_uid174_fpFusedAddSubTest_q <= not (positiveExc_uid173_fpFusedAddSubTest_q);

    -- redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11(DELAY,498)
    redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 10, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_sigb_uid10_uid30_fpFusedAddSubTest_q, xout => redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q, clk => clk, aclr => areset );

    -- signInputsZeroForSub_uid175_fpFusedAddSubTest(LOGICAL,174)@12
    signInputsZeroForSub_uid175_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q and redist48_sigA_uid43_fpFusedAddSubTest_b_11_q and redist47_sigB_uid44_fpFusedAddSubTest_b_12_q;

    -- invSignInputsZeroForSub_uid176_fpFusedAddSubTest(LOGICAL,175)@12
    invSignInputsZeroForSub_uid176_fpFusedAddSubTest_q <= not (signInputsZeroForSub_uid175_fpFusedAddSubTest_q);

    -- sigY_uid177_fpFusedAddSubTest(BITSELECT,176)@0
    sigY_uid177_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(b(39 downto 39));

    -- redist27_sigY_uid177_fpFusedAddSubTest_b_1(DELAY,472)
    redist27_sigY_uid177_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigY_uid177_fpFusedAddSubTest_b, xout => redist27_sigY_uid177_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- invSigY_uid178_fpFusedAddSubTest(LOGICAL,177)@1
    invSigY_uid178_fpFusedAddSubTest_q <= not (redist27_sigY_uid177_fpFusedAddSubTest_b_1_q);

    -- redist65_xGTEy_uid8_fpFusedAddSubTest_n_1(DELAY,510)
    redist65_xGTEy_uid8_fpFusedAddSubTest_n_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => xGTEy_uid8_fpFusedAddSubTest_n, xout => redist65_xGTEy_uid8_fpFusedAddSubTest_n_1_q, clk => clk, aclr => areset );

    -- invXGTEy_uid153_fpFusedAddSubTest(LOGICAL,152)@1
    invXGTEy_uid153_fpFusedAddSubTest_q <= not (redist65_xGTEy_uid8_fpFusedAddSubTest_n_1_q);

    -- yGTxYPos_uid180_fpFusedAddSubTest(LOGICAL,179)@1
    yGTxYPos_uid180_fpFusedAddSubTest_q <= invXGTEy_uid153_fpFusedAddSubTest_q and invSigY_uid178_fpFusedAddSubTest_q;

    -- sigX_uid181_fpFusedAddSubTest(BITSELECT,180)@0
    sigX_uid181_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(a(39 downto 39));

    -- redist26_sigX_uid181_fpFusedAddSubTest_b_1(DELAY,471)
    redist26_sigX_uid181_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sigX_uid181_fpFusedAddSubTest_b, xout => redist26_sigX_uid181_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- xGTyXNeg_uid182_fpFusedAddSubTest(LOGICAL,181)@1
    xGTyXNeg_uid182_fpFusedAddSubTest_q <= redist65_xGTEy_uid8_fpFusedAddSubTest_n_1_q and redist26_sigX_uid181_fpFusedAddSubTest_b_1_q;

    -- signRPostExcSub0_uid183_fpFusedAddSubTest(LOGICAL,182)@1 + 1
    signRPostExcSub0_uid183_fpFusedAddSubTest_qi <= xGTyXNeg_uid182_fpFusedAddSubTest_q or yGTxYPos_uid180_fpFusedAddSubTest_q;
    signRPostExcSub0_uid183_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExcSub0_uid183_fpFusedAddSubTest_qi, xout => signRPostExcSub0_uid183_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist25_signRPostExcSub0_uid183_fpFusedAddSubTest_q_11(DELAY,470)
    redist25_signRPostExcSub0_uid183_fpFusedAddSubTest_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 10, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExcSub0_uid183_fpFusedAddSubTest_q, xout => redist25_signRPostExcSub0_uid183_fpFusedAddSubTest_q_11_q, clk => clk, aclr => areset );

    -- fracXIsZero_uid32_fpFusedAddSubTest(LOGICAL,31)@2 + 1
    fracXIsZero_uid32_fpFusedAddSubTest_qi <= "1" WHEN cstZeroWF_uid12_fpFusedAddSubTest_q = redist56_frac_sigb_uid29_fpFusedAddSubTest_b_2_q ELSE "0";
    fracXIsZero_uid32_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid32_fpFusedAddSubTest_qi, xout => fracXIsZero_uid32_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10(DELAY,496)
    redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 9, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid32_fpFusedAddSubTest_q, xout => redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid33_fpFusedAddSubTest(LOGICAL,32)@12
    fracXIsNotZero_uid33_fpFusedAddSubTest_q <= not (redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10_q);

    -- expXIsMax_uid31_fpFusedAddSubTest(LOGICAL,30)@1 + 1
    expXIsMax_uid31_fpFusedAddSubTest_qi <= "1" WHEN redist57_exp_sigb_uid28_fpFusedAddSubTest_b_1_q = cstAllOWE_uid11_fpFusedAddSubTest_q ELSE "0";
    expXIsMax_uid31_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid31_fpFusedAddSubTest_qi, xout => expXIsMax_uid31_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11(DELAY,497)
    redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 10, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid31_fpFusedAddSubTest_q, xout => redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11_q, clk => clk, aclr => areset );

    -- excN_sigb_uid35_fpFusedAddSubTest(LOGICAL,34)@12
    excN_sigb_uid35_fpFusedAddSubTest_q <= redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11_q and fracXIsNotZero_uid33_fpFusedAddSubTest_q;

    -- fracXIsZero_uid18_fpFusedAddSubTest(LOGICAL,17)@5 + 1
    fracXIsZero_uid18_fpFusedAddSubTest_qi <= "1" WHEN cstZeroWF_uid12_fpFusedAddSubTest_q = redist63_frac_siga_uid15_fpFusedAddSubTest_b_4_q ELSE "0";
    fracXIsZero_uid18_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid18_fpFusedAddSubTest_qi, xout => fracXIsZero_uid18_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7(DELAY,505)
    redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid18_fpFusedAddSubTest_q, xout => redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7_q, clk => clk, aclr => areset );

    -- fracXIsNotZero_uid19_fpFusedAddSubTest(LOGICAL,18)@12
    fracXIsNotZero_uid19_fpFusedAddSubTest_q <= not (redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7_q);

    -- excN_siga_uid21_fpFusedAddSubTest(LOGICAL,20)@12
    excN_siga_uid21_fpFusedAddSubTest_q <= expXIsMax_uid17_fpFusedAddSubTest_q and fracXIsNotZero_uid19_fpFusedAddSubTest_q;

    -- effSub_uid45_fpFusedAddSubTest(LOGICAL,44)@12
    effSub_uid45_fpFusedAddSubTest_q <= redist48_sigA_uid43_fpFusedAddSubTest_b_11_q xor redist47_sigB_uid44_fpFusedAddSubTest_b_12_q;

    -- invEffSub_uid134_fpFusedAddSubTest(LOGICAL,133)@12
    invEffSub_uid134_fpFusedAddSubTest_q <= not (effSub_uid45_fpFusedAddSubTest_q);

    -- excI_sigb_uid34_fpFusedAddSubTest(LOGICAL,33)@12
    excI_sigb_uid34_fpFusedAddSubTest_q <= redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11_q and redist51_fracXIsZero_uid32_fpFusedAddSubTest_q_10_q;

    -- excI_siga_uid20_fpFusedAddSubTest(LOGICAL,19)@12
    excI_siga_uid20_fpFusedAddSubTest_q <= expXIsMax_uid17_fpFusedAddSubTest_q and redist60_fracXIsZero_uid18_fpFusedAddSubTest_q_7_q;

    -- infPinfForSub_uid135_fpFusedAddSubTest(LOGICAL,134)@12
    infPinfForSub_uid135_fpFusedAddSubTest_q <= excI_siga_uid20_fpFusedAddSubTest_q and excI_sigb_uid34_fpFusedAddSubTest_q and invEffSub_uid134_fpFusedAddSubTest_q;

    -- excRNaNS_uid136_fpFusedAddSubTest(LOGICAL,135)@12
    excRNaNS_uid136_fpFusedAddSubTest_q <= infPinfForSub_uid135_fpFusedAddSubTest_q or excN_siga_uid21_fpFusedAddSubTest_q or excN_sigb_uid35_fpFusedAddSubTest_q;

    -- invExcRNaNS_uid184_fpFusedAddSubTest(LOGICAL,183)@12
    invExcRNaNS_uid184_fpFusedAddSubTest_q <= not (excRNaNS_uid136_fpFusedAddSubTest_q);

    -- signRPostExcSub_uid185_fpFusedAddSubTest(LOGICAL,184)@12 + 1
    signRPostExcSub_uid185_fpFusedAddSubTest_qi <= invExcRNaNS_uid184_fpFusedAddSubTest_q and redist25_signRPostExcSub0_uid183_fpFusedAddSubTest_q_11_q and invSignInputsZeroForSub_uid176_fpFusedAddSubTest_q and invPositiveExc_uid174_fpFusedAddSubTest_q;
    signRPostExcSub_uid185_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExcSub_uid185_fpFusedAddSubTest_qi, xout => signRPostExcSub_uid185_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist24_signRPostExcSub_uid185_fpFusedAddSubTest_q_3(DELAY,469)
    redist24_signRPostExcSub_uid185_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExcSub_uid185_fpFusedAddSubTest_q, xout => redist24_signRPostExcSub_uid185_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- cRBit_sub_uid94_fpFusedAddSubTest(CONSTANT,93)
    cRBit_sub_uid94_fpFusedAddSubTest_q <= "01000";

    -- leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest(CONSTANT,325)
    leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q <= "000000000000000000000000000000000000";

    -- fracResAdd_uid72_fpFusedAddSubTest(ADD,71)@5
    fracResAdd_uid72_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("000" & fracAOp_uid69_fpFusedAddSubTest_q);
    fracResAdd_uid72_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & fracBOp_uid70_fpFusedAddSubTest_q);
    fracResAdd_uid72_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracResAdd_uid72_fpFusedAddSubTest_a) + UNSIGNED(fracResAdd_uid72_fpFusedAddSubTest_b));
    fracResAdd_uid72_fpFusedAddSubTest_q <= fracResAdd_uid72_fpFusedAddSubTest_o(37 downto 0);

    -- fracResAddNoSignExt_uid74_fpFusedAddSubTest(BITSELECT,73)@5
    fracResAddNoSignExt_uid74_fpFusedAddSubTest_in <= fracResAdd_uid72_fpFusedAddSubTest_q(35 downto 0);
    fracResAddNoSignExt_uid74_fpFusedAddSubTest_b <= fracResAddNoSignExt_uid74_fpFusedAddSubTest_in(35 downto 0);

    -- redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1(DELAY,485)
    redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 36, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracResAddNoSignExt_uid74_fpFusedAddSubTest_b, xout => redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest(BITSELECT,229)@6
    vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_in <= redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1_q(3 downto 0);
    vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b <= vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_in(3 downto 0);

    -- redist16_vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b_3(DELAY,461)
    redist16_vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b_3 : dspba_delay
    GENERIC MAP ( width => 4, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b, xout => redist16_vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b_3_q, clk => clk, aclr => areset );

    -- leftShiftStage0Idx4_uid368_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,367)@9
    leftShiftStage0Idx4_uid368_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= redist16_vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b_3_q & zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1(MUX,420)@9
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s, leftShiftStage0Idx4_uid368_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx4_uid368_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,363)@9
    leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q(11 downto 0);
    leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_in(11 downto 0);

    -- leftShiftStage0Idx3_uid365_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,364)@9
    leftShiftStage0Idx3_uid365_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage0Idx3Rng24_uid364_fracPostNormAdd_uid78_fpFusedAddSubTest_b & rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,360)@9
    leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q(19 downto 0);
    leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_in(19 downto 0);

    -- leftShiftStage0Idx2_uid362_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,361)@9
    leftShiftStage0Idx2_uid362_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage0Idx2Rng16_uid361_fracPostNormAdd_uid78_fpFusedAddSubTest_b & zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,357)@9
    leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q(27 downto 0);
    leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_in(27 downto 0);

    -- leftShiftStage0Idx1_uid359_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,358)@9
    leftShiftStage0Idx1_uid359_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage0Idx1Rng8_uid358_fracPostNormAdd_uid78_fpFusedAddSubTest_b & cstAllZWE_uid13_fpFusedAddSubTest_q;

    -- redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4(DELAY,486)
    redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4 : dspba_delay
    GENERIC MAP ( width => 36, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1_q, xout => redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q, clk => clk, aclr => areset );

    -- leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0(MUX,419)@9
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s, redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q, leftShiftStage0Idx1_uid359_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage0Idx2_uid362_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage0Idx3_uid365_fracPostNormAdd_uid78_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= redist41_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_4_q;
            WHEN "01" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx1_uid359_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx2_uid362_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx3_uid365_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid227_lzCountValAdd_uid77_fpFusedAddSubTest(BITSELECT,226)@6
    rVStage_uid227_lzCountValAdd_uid77_fpFusedAddSubTest_b <= redist40_fracResAddNoSignExt_uid74_fpFusedAddSubTest_b_1_q(35 downto 4);

    -- vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,227)@6
    vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid227_lzCountValAdd_uid77_fpFusedAddSubTest_b = zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist17_vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q_3(DELAY,462)
    redist17_vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q, xout => redist17_vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- cStage_uid231_lzCountValAdd_uid77_fpFusedAddSubTest(BITJOIN,230)@6
    cStage_uid231_lzCountValAdd_uid77_fpFusedAddSubTest_q <= vStage_uid230_lzCountValAdd_uid77_fpFusedAddSubTest_b & mO_uid192_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest(MUX,232)@6 + 1
    vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_s <= vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q;
    vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_s) IS
                WHEN "0" => vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q <= rVStage_uid227_lzCountValAdd_uid77_fpFusedAddSubTest_b;
                WHEN "1" => vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q <= cStage_uid231_lzCountValAdd_uid77_fpFusedAddSubTest_q;
                WHEN OTHERS => vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select(BITSELECT,433)@7
    rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q(31 downto 16);
    rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid233_lzCountValAdd_uid77_fpFusedAddSubTest_q(15 downto 0);

    -- vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,235)@7
    vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b = zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist15_vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q_2(DELAY,460)
    redist15_vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q, xout => redist15_vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest(MUX,238)@7
    vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_s <= vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q;
    vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_s, rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q <= rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q <= rVStage_uid235_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select(BITSELECT,434)@7
    rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q(15 downto 8);
    rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid239_lzCountValAdd_uid77_fpFusedAddSubTest_q(7 downto 0);

    -- vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,241)@7 + 1
    vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_qi <= "1" WHEN rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";
    vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_qi, xout => vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist14_vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q_2(DELAY,459)
    redist14_vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q, xout => redist14_vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,450)
    redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c, xout => redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1(DELAY,449)
    redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b, xout => redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest(MUX,244)@8
    vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_s <= vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q;
    vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_s, redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q, redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q <= redist4_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q <= redist5_rVStage_uid241_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select(BITSELECT,435)@8
    rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q(7 downto 4);
    rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid245_lzCountValAdd_uid77_fpFusedAddSubTest_q(3 downto 0);

    -- vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,247)@8
    vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b = zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";

    -- redist13_vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q_1(DELAY,458)
    redist13_vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q, xout => redist13_vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q_1_q, clk => clk, aclr => areset );

    -- vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest(MUX,250)@8
    vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_s <= vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q;
    vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_s, rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q <= rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q <= rVStage_uid247_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select(BITSELECT,436)@8
    rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q(3 downto 2);
    rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid251_lzCountValAdd_uid77_fpFusedAddSubTest_q(1 downto 0);

    -- vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,253)@8 + 1
    vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_qi <= "1" WHEN rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b = zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q ELSE "0";
    vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_qi, xout => vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,448)
    redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c, xout => redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1(DELAY,447)
    redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b, xout => redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest(MUX,256)@9
    vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_s <= vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_q;
    vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_s, redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q, redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q)
    BEGIN
        CASE (vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_q <= redist2_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_b_1_q;
            WHEN "1" => vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_q <= redist3_rVStage_uid253_lzCountValAdd_uid77_fpFusedAddSubTest_merged_bit_select_c_1_q;
            WHEN OTHERS => vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid259_lzCountValAdd_uid77_fpFusedAddSubTest(BITSELECT,258)@9
    rVStage_uid259_lzCountValAdd_uid77_fpFusedAddSubTest_b <= vStagei_uid257_lzCountValAdd_uid77_fpFusedAddSubTest_q(1 downto 1);

    -- vCount_uid260_lzCountValAdd_uid77_fpFusedAddSubTest(LOGICAL,259)@9
    vCount_uid260_lzCountValAdd_uid77_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid259_lzCountValAdd_uid77_fpFusedAddSubTest_b = GND_q ELSE "0";

    -- r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest(BITJOIN,260)@9
    r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q <= redist17_vCount_uid228_lzCountValAdd_uid77_fpFusedAddSubTest_q_3_q & redist15_vCount_uid236_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q & redist14_vCount_uid242_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q & redist13_vCount_uid248_lzCountValAdd_uid77_fpFusedAddSubTest_q_1_q & vCount_uid254_lzCountValAdd_uid77_fpFusedAddSubTest_q & vCount_uid260_lzCountValAdd_uid77_fpFusedAddSubTest_q;

    -- leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select(BITSELECT,437)@9
    leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_b <= r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q(5 downto 3);
    leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c <= r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q(2 downto 0);

    -- leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,443)@9
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal(MUX,421)@9 + 1
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,392)@10
    leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(28 downto 0);
    leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_in(28 downto 0);

    -- leftShiftStage1Idx7_uid394_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,393)@10
    leftShiftStage1Idx7_uid394_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx7Rng7_uid393_fracPostNormAdd_uid78_fpFusedAddSubTest_b & rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,389)@10
    leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(29 downto 0);
    leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_in(29 downto 0);

    -- leftShiftStage1Idx6_uid391_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,390)@10
    leftShiftStage1Idx6_uid391_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx6Rng6_uid390_fracPostNormAdd_uid78_fpFusedAddSubTest_b & rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,386)@10
    leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(30 downto 0);
    leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_in(30 downto 0);

    -- leftShiftStage1Idx5_uid388_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,387)@10
    leftShiftStage1Idx5_uid388_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx5Rng5_uid387_fracPostNormAdd_uid78_fpFusedAddSubTest_b & rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,383)@10
    leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(31 downto 0);
    leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_in(31 downto 0);

    -- leftShiftStage1Idx4_uid385_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,384)@10
    leftShiftStage1Idx4_uid385_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx4Rng4_uid384_fracPostNormAdd_uid78_fpFusedAddSubTest_b & zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1(MUX,425)@10
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s, leftShiftStage1Idx4_uid385_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage1Idx5_uid388_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage1Idx6_uid391_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage1Idx7_uid394_fracPostNormAdd_uid78_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx4_uid385_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx5_uid388_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx6_uid391_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx7_uid394_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,380)@10
    leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(32 downto 0);
    leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_in(32 downto 0);

    -- leftShiftStage1Idx3_uid382_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,381)@10
    leftShiftStage1Idx3_uid382_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx3Rng3_uid381_fracPostNormAdd_uid78_fpFusedAddSubTest_b & zv_uid68_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,377)@10
    leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(33 downto 0);
    leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_in(33 downto 0);

    -- leftShiftStage1Idx2_uid379_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,378)@10
    leftShiftStage1Idx2_uid379_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx2Rng2_uid378_fracPostNormAdd_uid78_fpFusedAddSubTest_b & zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest(BITSELECT,374)@10
    leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_in <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(34 downto 0);
    leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_b <= leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_in(34 downto 0);

    -- leftShiftStage1Idx1_uid376_fracPostNormAdd_uid78_fpFusedAddSubTest(BITJOIN,375)@10
    leftShiftStage1Idx1_uid376_fracPostNormAdd_uid78_fpFusedAddSubTest_q <= leftShiftStage1Idx1Rng1_uid375_fracPostNormAdd_uid78_fpFusedAddSubTest_b & GND_q;

    -- leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0(MUX,424)@10
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s, leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q, leftShiftStage1Idx1_uid376_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage1Idx2_uid379_fracPostNormAdd_uid78_fpFusedAddSubTest_q, leftShiftStage1Idx3_uid382_fracPostNormAdd_uid78_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0_uid373_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx1_uid376_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx2_uid379_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx3_uid382_fracPostNormAdd_uid78_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,446)
    redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 3, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c, xout => redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,444)@10
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1_q(1 downto 0);
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= redist1_leftShiftStageSel5Dto3_uid372_fracPostNormAdd_uid78_fpFusedAddSubTest_merged_bit_select_c_1_q(2 downto 2);

    -- leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal(MUX,426)@10 + 1
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- LSB_add_uid102_fpFusedAddSubTest(BITSELECT,101)@11
    LSB_add_uid102_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(4 downto 0));
    LSB_add_uid102_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(LSB_add_uid102_fpFusedAddSubTest_in(4 downto 4));

    -- Guard_add_uid101_fpFusedAddSubTest(BITSELECT,100)@11
    Guard_add_uid101_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(3 downto 0));
    Guard_add_uid101_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Guard_add_uid101_fpFusedAddSubTest_in(3 downto 3));

    -- Round_add_uid100_fpFusedAddSubTest(BITSELECT,99)@11
    Round_add_uid100_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(2 downto 0));
    Round_add_uid100_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Round_add_uid100_fpFusedAddSubTest_in(2 downto 2));

    -- sticky1_add_uid99_fpFusedAddSubTest(BITSELECT,98)@11
    sticky1_add_uid99_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(1 downto 0));
    sticky1_add_uid99_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(sticky1_add_uid99_fpFusedAddSubTest_in(1 downto 1));

    -- sticky0_add_uid98_fpFusedAddSubTest(BITSELECT,97)@11
    sticky0_add_uid98_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(0 downto 0));
    sticky0_add_uid98_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(sticky0_add_uid98_fpFusedAddSubTest_in(0 downto 0));

    -- rndBitCond_add_uid103_fpFusedAddSubTest(BITJOIN,102)@11
    rndBitCond_add_uid103_fpFusedAddSubTest_q <= LSB_add_uid102_fpFusedAddSubTest_b & Guard_add_uid101_fpFusedAddSubTest_b & Round_add_uid100_fpFusedAddSubTest_b & sticky1_add_uid99_fpFusedAddSubTest_b & sticky0_add_uid98_fpFusedAddSubTest_b;

    -- rBi_add_uid105_fpFusedAddSubTest(LOGICAL,104)@11 + 1
    rBi_add_uid105_fpFusedAddSubTest_qi <= "1" WHEN rndBitCond_add_uid103_fpFusedAddSubTest_q = cRBit_sub_uid94_fpFusedAddSubTest_q ELSE "0";
    rBi_add_uid105_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rBi_add_uid105_fpFusedAddSubTest_qi, xout => rBi_add_uid105_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- roundBit_add_uid106_fpFusedAddSubTest(LOGICAL,105)@12
    roundBit_add_uid106_fpFusedAddSubTest_q <= not (rBi_add_uid105_fpFusedAddSubTest_q);

    -- redist12_r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q_2(DELAY,457)
    redist12_r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 6, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q, xout => redist12_r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- expInc_uid81_fpFusedAddSubTest(ADD,80)@11
    expInc_uid81_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & redist64_exp_siga_uid14_fpFusedAddSubTest_b_10_q);
    expInc_uid81_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00000000" & VCC_q);
    expInc_uid81_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expInc_uid81_fpFusedAddSubTest_a) + UNSIGNED(expInc_uid81_fpFusedAddSubTest_b));
    expInc_uid81_fpFusedAddSubTest_q <= expInc_uid81_fpFusedAddSubTest_o(8 downto 0);

    -- expPostNormAdd_uid83_fpFusedAddSubTest(SUB,82)@11 + 1
    expPostNormAdd_uid83_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid81_fpFusedAddSubTest_q);
    expPostNormAdd_uid83_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0000" & redist12_r_uid261_lzCountValAdd_uid77_fpFusedAddSubTest_q_2_q);
    expPostNormAdd_uid83_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expPostNormAdd_uid83_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expPostNormAdd_uid83_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNormAdd_uid83_fpFusedAddSubTest_a) - UNSIGNED(expPostNormAdd_uid83_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    expPostNormAdd_uid83_fpFusedAddSubTest_q <= expPostNormAdd_uid83_fpFusedAddSubTest_o(9 downto 0);

    -- fracPostNormAddRndRange_uid86_fpFusedAddSubTest(BITSELECT,85)@11
    fracPostNormAddRndRange_uid86_fpFusedAddSubTest_in <= leftShiftStage1_uid396_fracPostNormAdd_uid78_fpFusedAddSubTest_mfinal_q(34 downto 0);
    fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b <= fracPostNormAddRndRange_uid86_fpFusedAddSubTest_in(34 downto 3);

    -- redist37_fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b_1(DELAY,482)
    redist37_fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b, xout => redist37_fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- expFracRAdd_uid87_fpFusedAddSubTest(BITJOIN,86)@12
    expFracRAdd_uid87_fpFusedAddSubTest_q <= expPostNormAdd_uid83_fpFusedAddSubTest_q & redist37_fracPostNormAddRndRange_uid86_fpFusedAddSubTest_b_1_q;

    -- expFracRAddPostRound_uid107_fpFusedAddSubTest(ADD,106)@12 + 1
    expFracRAddPostRound_uid107_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expFracRAdd_uid87_fpFusedAddSubTest_q);
    expFracRAddPostRound_uid107_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("000000000000000000000000000000000000000000" & roundBit_add_uid106_fpFusedAddSubTest_q);
    expFracRAddPostRound_uid107_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expFracRAddPostRound_uid107_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expFracRAddPostRound_uid107_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expFracRAddPostRound_uid107_fpFusedAddSubTest_a) + UNSIGNED(expFracRAddPostRound_uid107_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    expFracRAddPostRound_uid107_fpFusedAddSubTest_q <= expFracRAddPostRound_uid107_fpFusedAddSubTest_o(42 downto 0);

    -- expRPreExcAdd_uid117_fpFusedAddSubTest(BITSELECT,116)@13
    expRPreExcAdd_uid117_fpFusedAddSubTest_in <= expFracRAddPostRound_uid107_fpFusedAddSubTest_q(39 downto 0);
    expRPreExcAdd_uid117_fpFusedAddSubTest_b <= expRPreExcAdd_uid117_fpFusedAddSubTest_in(39 downto 32);

    -- redist22_vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b_3(DELAY,467)
    redist22_vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b_3 : dspba_delay
    GENERIC MAP ( width => 4, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b, xout => redist22_vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b_3_q, clk => clk, aclr => areset );

    -- leftShiftStage0Idx4_uid325_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,324)@9
    leftShiftStage0Idx4_uid325_fracPostNormSub_uid76_fpFusedAddSubTest_q <= redist22_vStage_uid193_lzCountValSub_uid75_fpFusedAddSubTest_b_3_q & zs_uid189_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1(MUX,410)@9
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s, leftShiftStage0Idx4_uid325_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx4_uid325_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid326_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,320)@9
    leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_in <= redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q(11 downto 0);
    leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_in(11 downto 0);

    -- leftShiftStage0Idx3_uid322_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,321)@9
    leftShiftStage0Idx3_uid322_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage0Idx3Rng24_uid321_fracPostNormSub_uid76_fpFusedAddSubTest_b & rightShiftStage0Idx3Pad24_uid272_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,317)@9
    leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_in <= redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q(19 downto 0);
    leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_in(19 downto 0);

    -- leftShiftStage0Idx2_uid319_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,318)@9
    leftShiftStage0Idx2_uid319_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage0Idx2Rng16_uid318_fracPostNormSub_uid76_fpFusedAddSubTest_b & zs_uid197_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,314)@9
    leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_in <= redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q(27 downto 0);
    leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_in(27 downto 0);

    -- leftShiftStage0Idx1_uid316_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,315)@9
    leftShiftStage0Idx1_uid316_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage0Idx1Rng8_uid315_fracPostNormSub_uid76_fpFusedAddSubTest_b & cstAllZWE_uid13_fpFusedAddSubTest_q;

    -- redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4(DELAY,488)
    redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4 : dspba_delay
    GENERIC MAP ( width => 36, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist42_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_1_q, xout => redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q, clk => clk, aclr => areset );

    -- leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0(MUX,409)@9
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s, redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q, leftShiftStage0Idx1_uid316_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage0Idx2_uid319_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage0Idx3_uid322_fracPostNormSub_uid76_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= redist43_fracResSubNoSignExt_uid73_fpFusedAddSubTest_b_4_q;
            WHEN "01" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx1_uid316_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx2_uid319_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx3_uid322_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select(BITSELECT,432)@9
    leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_b <= r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q(5 downto 3);
    leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c <= r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q(2 downto 0);

    -- leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,441)@9
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal(MUX,411)@9 + 1
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,349)@10
    leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(28 downto 0);
    leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_in(28 downto 0);

    -- leftShiftStage1Idx7_uid351_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,350)@10
    leftShiftStage1Idx7_uid351_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx7Rng7_uid350_fracPostNormSub_uid76_fpFusedAddSubTest_b & rightShiftStage1Idx7Pad7_uid307_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,346)@10
    leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(29 downto 0);
    leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_in(29 downto 0);

    -- leftShiftStage1Idx6_uid348_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,347)@10
    leftShiftStage1Idx6_uid348_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx6Rng6_uid347_fracPostNormSub_uid76_fpFusedAddSubTest_b & rightShiftStage1Idx6Pad6_uid304_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,343)@10
    leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(30 downto 0);
    leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_in(30 downto 0);

    -- leftShiftStage1Idx5_uid345_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,344)@10
    leftShiftStage1Idx5_uid345_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx5Rng5_uid344_fracPostNormSub_uid76_fpFusedAddSubTest_b & rightShiftStage1Idx5Pad5_uid301_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,340)@10
    leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(31 downto 0);
    leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_in(31 downto 0);

    -- leftShiftStage1Idx4_uid342_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,341)@10
    leftShiftStage1Idx4_uid342_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx4Rng4_uid341_fracPostNormSub_uid76_fpFusedAddSubTest_b & zs_uid209_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1(MUX,415)@10
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s, leftShiftStage1Idx4_uid342_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage1Idx5_uid345_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage1Idx6_uid348_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage1Idx7_uid351_fracPostNormSub_uid76_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx4_uid342_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx5_uid345_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx6_uid348_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= leftShiftStage1Idx7_uid351_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,337)@10
    leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(32 downto 0);
    leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_in(32 downto 0);

    -- leftShiftStage1Idx3_uid339_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,338)@10
    leftShiftStage1Idx3_uid339_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx3Rng3_uid338_fracPostNormSub_uid76_fpFusedAddSubTest_b & zv_uid68_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,334)@10
    leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(33 downto 0);
    leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_in(33 downto 0);

    -- leftShiftStage1Idx2_uid336_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,335)@10
    leftShiftStage1Idx2_uid336_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx2Rng2_uid335_fracPostNormSub_uid76_fpFusedAddSubTest_b & zs_uid215_lzCountValSub_uid75_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest(BITSELECT,331)@10
    leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_in <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(34 downto 0);
    leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_b <= leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_in(34 downto 0);

    -- leftShiftStage1Idx1_uid333_fracPostNormSub_uid76_fpFusedAddSubTest(BITJOIN,332)@10
    leftShiftStage1Idx1_uid333_fracPostNormSub_uid76_fpFusedAddSubTest_q <= leftShiftStage1Idx1Rng1_uid332_fracPostNormSub_uid76_fpFusedAddSubTest_b & GND_q;

    -- leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0(MUX,414)@10
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s, leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q, leftShiftStage1Idx1_uid333_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage1Idx2_uid336_fracPostNormSub_uid76_fpFusedAddSubTest_q, leftShiftStage1Idx3_uid339_fracPostNormSub_uid76_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0_uid330_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx1_uid333_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx2_uid336_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= leftShiftStage1Idx3_uid339_fracPostNormSub_uid76_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1(DELAY,451)
    redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1 : dspba_delay
    GENERIC MAP ( width => 3, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c, xout => redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1_q, clk => clk, aclr => areset );

    -- leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,442)@10
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1_q(1 downto 0);
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= redist6_leftShiftStageSel5Dto3_uid329_fracPostNormSub_uid76_fpFusedAddSubTest_merged_bit_select_c_1_q(2 downto 2);

    -- leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal(MUX,416)@10 + 1
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_s) IS
                WHEN "0" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_0_q;
                WHEN "1" => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_msplit_1_q;
                WHEN OTHERS => leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- LSB_sub_uid92_fpFusedAddSubTest(BITSELECT,91)@11
    LSB_sub_uid92_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(4 downto 0));
    LSB_sub_uid92_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(LSB_sub_uid92_fpFusedAddSubTest_in(4 downto 4));

    -- Guard_sub_uid91_fpFusedAddSubTest(BITSELECT,90)@11
    Guard_sub_uid91_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(3 downto 0));
    Guard_sub_uid91_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Guard_sub_uid91_fpFusedAddSubTest_in(3 downto 3));

    -- Round_sub_uid90_fpFusedAddSubTest(BITSELECT,89)@11
    Round_sub_uid90_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(2 downto 0));
    Round_sub_uid90_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Round_sub_uid90_fpFusedAddSubTest_in(2 downto 2));

    -- Sticky1_sub_uid89_fpFusedAddSubTest(BITSELECT,88)@11
    Sticky1_sub_uid89_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(1 downto 0));
    Sticky1_sub_uid89_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Sticky1_sub_uid89_fpFusedAddSubTest_in(1 downto 1));

    -- Sticky0_sub_uid88_fpFusedAddSubTest(BITSELECT,87)@11
    Sticky0_sub_uid88_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(0 downto 0));
    Sticky0_sub_uid88_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(Sticky0_sub_uid88_fpFusedAddSubTest_in(0 downto 0));

    -- rndBitCond_sub_uid93_fpFusedAddSubTest(BITJOIN,92)@11
    rndBitCond_sub_uid93_fpFusedAddSubTest_q <= LSB_sub_uid92_fpFusedAddSubTest_b & Guard_sub_uid91_fpFusedAddSubTest_b & Round_sub_uid90_fpFusedAddSubTest_b & Sticky1_sub_uid89_fpFusedAddSubTest_b & Sticky0_sub_uid88_fpFusedAddSubTest_b;

    -- rBi_sub_uid95_fpFusedAddSubTest(LOGICAL,94)@11 + 1
    rBi_sub_uid95_fpFusedAddSubTest_qi <= "1" WHEN rndBitCond_sub_uid93_fpFusedAddSubTest_q = cRBit_sub_uid94_fpFusedAddSubTest_q ELSE "0";
    rBi_sub_uid95_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rBi_sub_uid95_fpFusedAddSubTest_qi, xout => rBi_sub_uid95_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- roundBit_sub_uid96_fpFusedAddSubTest(LOGICAL,95)@12
    roundBit_sub_uid96_fpFusedAddSubTest_q <= not (rBi_sub_uid95_fpFusedAddSubTest_q);

    -- expPostNormSub_uid82_fpFusedAddSubTest(SUB,81)@11 + 1
    expPostNormSub_uid82_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid81_fpFusedAddSubTest_q);
    expPostNormSub_uid82_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0000" & redist18_r_uid224_lzCountValSub_uid75_fpFusedAddSubTest_q_2_q);
    expPostNormSub_uid82_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expPostNormSub_uid82_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expPostNormSub_uid82_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNormSub_uid82_fpFusedAddSubTest_a) - UNSIGNED(expPostNormSub_uid82_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    expPostNormSub_uid82_fpFusedAddSubTest_q <= expPostNormSub_uid82_fpFusedAddSubTest_o(9 downto 0);

    -- fracPostNormSubRndRange_uid84_fpFusedAddSubTest(BITSELECT,83)@11
    fracPostNormSubRndRange_uid84_fpFusedAddSubTest_in <= leftShiftStage1_uid353_fracPostNormSub_uid76_fpFusedAddSubTest_mfinal_q(34 downto 0);
    fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b <= fracPostNormSubRndRange_uid84_fpFusedAddSubTest_in(34 downto 3);

    -- redist38_fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b_1(DELAY,483)
    redist38_fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b, xout => redist38_fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b_1_q, clk => clk, aclr => areset );

    -- expFracRSub_uid85_fpFusedAddSubTest(BITJOIN,84)@12
    expFracRSub_uid85_fpFusedAddSubTest_q <= expPostNormSub_uid82_fpFusedAddSubTest_q & redist38_fracPostNormSubRndRange_uid84_fpFusedAddSubTest_b_1_q;

    -- expFracRSubPostRound_uid97_fpFusedAddSubTest(ADD,96)@12 + 1
    expFracRSubPostRound_uid97_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expFracRSub_uid85_fpFusedAddSubTest_q);
    expFracRSubPostRound_uid97_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("000000000000000000000000000000000000000000" & roundBit_sub_uid96_fpFusedAddSubTest_q);
    expFracRSubPostRound_uid97_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expFracRSubPostRound_uid97_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expFracRSubPostRound_uid97_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expFracRSubPostRound_uid97_fpFusedAddSubTest_a) + UNSIGNED(expFracRSubPostRound_uid97_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    expFracRSubPostRound_uid97_fpFusedAddSubTest_q <= expFracRSubPostRound_uid97_fpFusedAddSubTest_o(42 downto 0);

    -- expRPreExcSub_uid114_fpFusedAddSubTest(BITSELECT,113)@13
    expRPreExcSub_uid114_fpFusedAddSubTest_in <= expFracRSubPostRound_uid97_fpFusedAddSubTest_q(39 downto 0);
    expRPreExcSub_uid114_fpFusedAddSubTest_b <= expRPreExcSub_uid114_fpFusedAddSubTest_in(39 downto 32);

    -- redist45_effSub_uid45_fpFusedAddSubTest_q_1(DELAY,490)
    redist45_effSub_uid45_fpFusedAddSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => effSub_uid45_fpFusedAddSubTest_q, xout => redist45_effSub_uid45_fpFusedAddSubTest_q_1_q, clk => clk, aclr => areset );

    -- expRPreExcSubtraction_uid144_fpFusedAddSubTest(MUX,143)@13 + 1
    expRPreExcSubtraction_uid144_fpFusedAddSubTest_s <= redist45_effSub_uid45_fpFusedAddSubTest_q_1_q;
    expRPreExcSubtraction_uid144_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expRPreExcSubtraction_uid144_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (expRPreExcSubtraction_uid144_fpFusedAddSubTest_s) IS
                WHEN "0" => expRPreExcSubtraction_uid144_fpFusedAddSubTest_q <= expRPreExcSub_uid114_fpFusedAddSubTest_b;
                WHEN "1" => expRPreExcSubtraction_uid144_fpFusedAddSubTest_q <= expRPreExcAdd_uid117_fpFusedAddSubTest_b;
                WHEN OTHERS => expRPreExcSubtraction_uid144_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2(DELAY,475)
    redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExcSubtraction_uid144_fpFusedAddSubTest_q, xout => redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist34_excRNaNS_uid136_fpFusedAddSubTest_q_3(DELAY,479)
    redist34_excRNaNS_uid136_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaNS_uid136_fpFusedAddSubTest_q, xout => redist34_excRNaNS_uid136_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- wEP2AllOwE_uid108_fpFusedAddSubTest(CONSTANT,107)
    wEP2AllOwE_uid108_fpFusedAddSubTest_q <= "0011111111";

    -- rndExp_uid109_fpFusedAddSubTest(BITSELECT,108)@13
    rndExp_uid109_fpFusedAddSubTest_in <= expFracRAddPostRound_uid107_fpFusedAddSubTest_q(41 downto 0);
    rndExp_uid109_fpFusedAddSubTest_b <= rndExp_uid109_fpFusedAddSubTest_in(41 downto 32);

    -- rOvf_uid110_fpFusedAddSubTest(LOGICAL,109)@13
    rOvf_uid110_fpFusedAddSubTest_q <= "1" WHEN rndExp_uid109_fpFusedAddSubTest_b = wEP2AllOwE_uid108_fpFusedAddSubTest_q ELSE "0";

    -- invExpXIsMax_uid36_fpFusedAddSubTest(LOGICAL,35)@12
    invExpXIsMax_uid36_fpFusedAddSubTest_q <= not (redist52_expXIsMax_uid31_fpFusedAddSubTest_q_11_q);

    -- redist49_InvExpXIsZero_uid37_fpFusedAddSubTest_q_10(DELAY,494)
    redist49_InvExpXIsZero_uid37_fpFusedAddSubTest_q_10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 10, reset_kind => "ASYNC" )
    PORT MAP ( xin => InvExpXIsZero_uid37_fpFusedAddSubTest_q, xout => redist49_InvExpXIsZero_uid37_fpFusedAddSubTest_q_10_q, clk => clk, aclr => areset );

    -- excR_sigb_uid38_fpFusedAddSubTest(LOGICAL,37)@12 + 1
    excR_sigb_uid38_fpFusedAddSubTest_qi <= redist49_InvExpXIsZero_uid37_fpFusedAddSubTest_q_10_q and invExpXIsMax_uid36_fpFusedAddSubTest_q;
    excR_sigb_uid38_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_sigb_uid38_fpFusedAddSubTest_qi, xout => excR_sigb_uid38_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist58_excR_siga_uid24_fpFusedAddSubTest_q_1(DELAY,503)
    redist58_excR_siga_uid24_fpFusedAddSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excR_siga_uid24_fpFusedAddSubTest_q, xout => redist58_excR_siga_uid24_fpFusedAddSubTest_q_1_q, clk => clk, aclr => areset );

    -- regInputs_uid119_fpFusedAddSubTest(LOGICAL,118)@13
    regInputs_uid119_fpFusedAddSubTest_q <= redist58_excR_siga_uid24_fpFusedAddSubTest_q_1_q and excR_sigb_uid38_fpFusedAddSubTest_q;

    -- regInAndOvf_uid123_fpFusedAddSubTest(LOGICAL,122)@13 + 1
    regInAndOvf_uid123_fpFusedAddSubTest_qi <= regInputs_uid119_fpFusedAddSubTest_q and rOvf_uid110_fpFusedAddSubTest_q;
    regInAndOvf_uid123_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regInAndOvf_uid123_fpFusedAddSubTest_qi, xout => regInAndOvf_uid123_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12(DELAY,499)
    redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q, xout => redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12_q, clk => clk, aclr => areset );

    -- redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13(DELAY,500)
    redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12_q, xout => redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13_q, clk => clk, aclr => areset );

    -- redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2(DELAY,506)
    redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_siga_uid9_uid16_fpFusedAddSubTest_q, xout => redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3(DELAY,507)
    redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2_q, xout => redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2(DELAY,495)
    redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_sigb_uid34_fpFusedAddSubTest_q, xout => redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist59_excI_siga_uid20_fpFusedAddSubTest_q_2(DELAY,504)
    redist59_excI_siga_uid20_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => excI_siga_uid20_fpFusedAddSubTest_q, xout => redist59_excI_siga_uid20_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist46_effSub_uid45_fpFusedAddSubTest_q_2(DELAY,491)
    redist46_effSub_uid45_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist45_effSub_uid45_fpFusedAddSubTest_q_1_q, xout => redist46_effSub_uid45_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- excRInfVInC_uid127_fpFusedAddSubTest(BITJOIN,126)@14
    excRInfVInC_uid127_fpFusedAddSubTest_q <= regInAndOvf_uid123_fpFusedAddSubTest_q & redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13_q & redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3_q & redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2_q & redist59_excI_siga_uid20_fpFusedAddSubTest_q_2_q & redist46_effSub_uid45_fpFusedAddSubTest_q_2_q;

    -- excRInfSub_uid130_fpFusedAddSubTest(LOOKUP,129)@14 + 1
    excRInfSub_uid130_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRInfVInC_uid127_fpFusedAddSubTest_q) IS
                WHEN "000000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "000111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "001000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "001001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "001010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "001011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "001100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "001101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "001110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "001111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "010011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "010100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "010111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "011111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "1";
                WHEN "100010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "100111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "101111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "110111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111000" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111001" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111010" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111011" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111100" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111101" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111110" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN "111111" => excRInfSub_uid130_fpFusedAddSubTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRInfSub_uid130_fpFusedAddSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- oneIsInfOrZero_uid125_fpFusedAddSubTest(LOGICAL,124)@13 + 1
    oneIsInfOrZero_uid125_fpFusedAddSubTest_qi <= redist58_excR_siga_uid24_fpFusedAddSubTest_q_1_q or excR_sigb_uid38_fpFusedAddSubTest_q or redist61_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_2_q or redist54_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_12_q;
    oneIsInfOrZero_uid125_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => oneIsInfOrZero_uid125_fpFusedAddSubTest_qi, xout => oneIsInfOrZero_uid125_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- oneIsInf_uid124_fpFusedAddSubTest(LOGICAL,123)@14
    oneIsInf_uid124_fpFusedAddSubTest_q <= redist59_excI_siga_uid20_fpFusedAddSubTest_q_2_q or redist50_excI_sigb_uid34_fpFusedAddSubTest_q_2_q;

    -- addIsAlsoInf_uid126_fpFusedAddSubTest(LOGICAL,125)@14 + 1
    addIsAlsoInf_uid126_fpFusedAddSubTest_qi <= oneIsInf_uid124_fpFusedAddSubTest_q and oneIsInfOrZero_uid125_fpFusedAddSubTest_q;
    addIsAlsoInf_uid126_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => addIsAlsoInf_uid126_fpFusedAddSubTest_qi, xout => addIsAlsoInf_uid126_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- excRInfSubFull_uid131_fpFusedAddSubTest(LOGICAL,130)@15
    excRInfSubFull_uid131_fpFusedAddSubTest_q <= addIsAlsoInf_uid126_fpFusedAddSubTest_q or excRInfSub_uid130_fpFusedAddSubTest_q;

    -- redist39_aMinusA_uid80_fpFusedAddSubTest_q_3(DELAY,484)
    redist39_aMinusA_uid80_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => aMinusA_uid80_fpFusedAddSubTest_q, xout => redist39_aMinusA_uid80_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- signedExp_uid111_fpFusedAddSubTest(BITSELECT,110)@13
    signedExp_uid111_fpFusedAddSubTest_in <= STD_LOGIC_VECTOR(expFracRSubPostRound_uid97_fpFusedAddSubTest_q(41 downto 0));
    signedExp_uid111_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(signedExp_uid111_fpFusedAddSubTest_in(41 downto 32));

    -- rUdf_uid112_fpFusedAddSubTest(COMPARE,111)@13 + 1
    rUdf_uid112_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000000000" & GND_q));
    rUdf_uid112_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 10 => signedExp_uid111_fpFusedAddSubTest_b(9)) & signedExp_uid111_fpFusedAddSubTest_b));
    rUdf_uid112_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            rUdf_uid112_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            rUdf_uid112_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(SIGNED(rUdf_uid112_fpFusedAddSubTest_a) - SIGNED(rUdf_uid112_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    rUdf_uid112_fpFusedAddSubTest_n(0) <= not (rUdf_uid112_fpFusedAddSubTest_o(11));

    -- redist36_regInputs_uid119_fpFusedAddSubTest_q_1(DELAY,481)
    redist36_regInputs_uid119_fpFusedAddSubTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regInputs_uid119_fpFusedAddSubTest_q, xout => redist36_regInputs_uid119_fpFusedAddSubTest_q_1_q, clk => clk, aclr => areset );

    -- excRZeroVInC_uid120_fpFusedAddSubTest(BITJOIN,119)@14
    excRZeroVInC_uid120_fpFusedAddSubTest_q <= redist46_effSub_uid45_fpFusedAddSubTest_q_2_q & redist39_aMinusA_uid80_fpFusedAddSubTest_q_3_q & rUdf_uid112_fpFusedAddSubTest_n & redist36_regInputs_uid119_fpFusedAddSubTest_q_1_q & redist55_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_13_q & redist62_excZ_siga_uid9_uid16_fpFusedAddSubTest_q_3_q;

    -- excRZeroSub_uid122_fpFusedAddSubTest(LOOKUP,121)@14 + 1
    excRZeroSub_uid122_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRZeroVInC_uid120_fpFusedAddSubTest_q) IS
                WHEN "000000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "1";
                WHEN "000100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "000111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "1";
                WHEN "001101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "001111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "1";
                WHEN "010101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "010111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "1";
                WHEN "011101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "011111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "100111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "101111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "110111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111000" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111001" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111010" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111011" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111100" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111101" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111110" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN "111111" => excRZeroSub_uid122_fpFusedAddSubTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRZeroSub_uid122_fpFusedAddSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- concExcSub_uid137_fpFusedAddSubTest(BITJOIN,136)@15
    concExcSub_uid137_fpFusedAddSubTest_q <= redist34_excRNaNS_uid136_fpFusedAddSubTest_q_3_q & excRInfSubFull_uid131_fpFusedAddSubTest_q & excRZeroSub_uid122_fpFusedAddSubTest_q;

    -- excREncSub_uid139_fpFusedAddSubTest(LOOKUP,138)@15
    excREncSub_uid139_fpFusedAddSubTest_combproc: PROCESS (concExcSub_uid137_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExcSub_uid137_fpFusedAddSubTest_q) IS
            WHEN "000" => excREncSub_uid139_fpFusedAddSubTest_q <= "01";
            WHEN "001" => excREncSub_uid139_fpFusedAddSubTest_q <= "00";
            WHEN "010" => excREncSub_uid139_fpFusedAddSubTest_q <= "10";
            WHEN "011" => excREncSub_uid139_fpFusedAddSubTest_q <= "00";
            WHEN "100" => excREncSub_uid139_fpFusedAddSubTest_q <= "11";
            WHEN "101" => excREncSub_uid139_fpFusedAddSubTest_q <= "00";
            WHEN "110" => excREncSub_uid139_fpFusedAddSubTest_q <= "00";
            WHEN "111" => excREncSub_uid139_fpFusedAddSubTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREncSub_uid139_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExcSub_uid172_fpFusedAddSubTest(MUX,171)@15
    expRPostExcSub_uid172_fpFusedAddSubTest_s <= excREncSub_uid139_fpFusedAddSubTest_q;
    expRPostExcSub_uid172_fpFusedAddSubTest_combproc: PROCESS (expRPostExcSub_uid172_fpFusedAddSubTest_s, cstAllZWE_uid13_fpFusedAddSubTest_q, redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2_q, cstAllOWE_uid11_fpFusedAddSubTest_q)
    BEGIN
        CASE (expRPostExcSub_uid172_fpFusedAddSubTest_s) IS
            WHEN "00" => expRPostExcSub_uid172_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q;
            WHEN "01" => expRPostExcSub_uid172_fpFusedAddSubTest_q <= redist30_expRPreExcSubtraction_uid144_fpFusedAddSubTest_q_2_q;
            WHEN "10" => expRPostExcSub_uid172_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN "11" => expRPostExcSub_uid172_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN OTHERS => expRPostExcSub_uid172_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid145_fpFusedAddSubTest(CONSTANT,144)
    oneFracRPostExc2_uid145_fpFusedAddSubTest_q <= "0000000000000000000000000000001";

    -- fracRPreExcAdd_uid116_fpFusedAddSubTest(BITSELECT,115)@13
    fracRPreExcAdd_uid116_fpFusedAddSubTest_in <= expFracRAddPostRound_uid107_fpFusedAddSubTest_q(31 downto 0);
    fracRPreExcAdd_uid116_fpFusedAddSubTest_b <= fracRPreExcAdd_uid116_fpFusedAddSubTest_in(31 downto 1);

    -- fracRPreExcSub_uid113_fpFusedAddSubTest(BITSELECT,112)@13
    fracRPreExcSub_uid113_fpFusedAddSubTest_in <= expFracRSubPostRound_uid97_fpFusedAddSubTest_q(31 downto 0);
    fracRPreExcSub_uid113_fpFusedAddSubTest_b <= fracRPreExcSub_uid113_fpFusedAddSubTest_in(31 downto 1);

    -- fracRPreExcSubtraction_uid143_fpFusedAddSubTest(MUX,142)@13 + 1
    fracRPreExcSubtraction_uid143_fpFusedAddSubTest_s <= redist45_effSub_uid45_fpFusedAddSubTest_q_1_q;
    fracRPreExcSubtraction_uid143_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRPreExcSubtraction_uid143_fpFusedAddSubTest_s) IS
                WHEN "0" => fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q <= fracRPreExcSub_uid113_fpFusedAddSubTest_b;
                WHEN "1" => fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q <= fracRPreExcAdd_uid116_fpFusedAddSubTest_b;
                WHEN OTHERS => fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2(DELAY,476)
    redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q, xout => redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- fracRPostExcSub_uid168_fpFusedAddSubTest(MUX,167)@15
    fracRPostExcSub_uid168_fpFusedAddSubTest_s <= excREncSub_uid139_fpFusedAddSubTest_q;
    fracRPostExcSub_uid168_fpFusedAddSubTest_combproc: PROCESS (fracRPostExcSub_uid168_fpFusedAddSubTest_s, cstZeroWF_uid12_fpFusedAddSubTest_q, redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2_q, oneFracRPostExc2_uid145_fpFusedAddSubTest_q)
    BEGIN
        CASE (fracRPostExcSub_uid168_fpFusedAddSubTest_s) IS
            WHEN "00" => fracRPostExcSub_uid168_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "01" => fracRPostExcSub_uid168_fpFusedAddSubTest_q <= redist31_fracRPreExcSubtraction_uid143_fpFusedAddSubTest_q_2_q;
            WHEN "10" => fracRPostExcSub_uid168_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "11" => fracRPostExcSub_uid168_fpFusedAddSubTest_q <= oneFracRPostExc2_uid145_fpFusedAddSubTest_q;
            WHEN OTHERS => fracRPostExcSub_uid168_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- RDiff_uid186_fpFusedAddSubTest(BITJOIN,185)@15
    RDiff_uid186_fpFusedAddSubTest_q <= redist24_signRPostExcSub_uid185_fpFusedAddSubTest_q_3_q & expRPostExcSub_uid172_fpFusedAddSubTest_q & fracRPostExcSub_uid168_fpFusedAddSubTest_q;

    -- redist29_invXGTEy_uid153_fpFusedAddSubTest_q_11(DELAY,474)
    redist29_invXGTEy_uid153_fpFusedAddSubTest_q_11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => invXGTEy_uid153_fpFusedAddSubTest_q, xout => redist29_invXGTEy_uid153_fpFusedAddSubTest_q_11_q, clk => clk, aclr => areset );

    -- invSigA_uid154_fpFusedAddSubTest(LOGICAL,153)@12
    invSigA_uid154_fpFusedAddSubTest_q <= not (redist48_sigA_uid43_fpFusedAddSubTest_b_11_q);

    -- signInputsZeroSwap_uid155_fpFusedAddSubTest(LOGICAL,154)@12
    signInputsZeroSwap_uid155_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q and invSigA_uid154_fpFusedAddSubTest_q and redist47_sigB_uid44_fpFusedAddSubTest_b_12_q and redist29_invXGTEy_uid153_fpFusedAddSubTest_q_11_q;

    -- invSignInputsZeroSwap_uid156_fpFusedAddSubTest(LOGICAL,155)@12
    invSignInputsZeroSwap_uid156_fpFusedAddSubTest_q <= not (signInputsZeroSwap_uid155_fpFusedAddSubTest_q);

    -- redist66_xGTEy_uid8_fpFusedAddSubTest_n_12(DELAY,511)
    redist66_xGTEy_uid8_fpFusedAddSubTest_n_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 11, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist65_xGTEy_uid8_fpFusedAddSubTest_n_1_q, xout => redist66_xGTEy_uid8_fpFusedAddSubTest_n_12_q, clk => clk, aclr => areset );

    -- invSigB_uid157_fpFusedAddSubTest(LOGICAL,156)@12
    invSigB_uid157_fpFusedAddSubTest_q <= not (redist47_sigB_uid44_fpFusedAddSubTest_b_12_q);

    -- signInputsZeroNoSwap_uid158_fpFusedAddSubTest(LOGICAL,157)@12
    signInputsZeroNoSwap_uid158_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and redist53_excZ_sigb_uid10_uid30_fpFusedAddSubTest_q_11_q and redist48_sigA_uid43_fpFusedAddSubTest_b_11_q and invSigB_uid157_fpFusedAddSubTest_q and redist66_xGTEy_uid8_fpFusedAddSubTest_n_12_q;

    -- invSignInputsZeroNoSwap_uid159_fpFusedAddSubTest(LOGICAL,158)@12
    invSignInputsZeroNoSwap_uid159_fpFusedAddSubTest_q <= not (signInputsZeroNoSwap_uid158_fpFusedAddSubTest_q);

    -- aMa_uid160_fpFusedAddSubTest(LOGICAL,159)@12
    aMa_uid160_fpFusedAddSubTest_q <= aMinusA_uid80_fpFusedAddSubTest_q and effSub_uid45_fpFusedAddSubTest_q;

    -- invAMA_uid161_fpFusedAddSubTest(LOGICAL,160)@12
    invAMA_uid161_fpFusedAddSubTest_q <= not (aMa_uid160_fpFusedAddSubTest_q);

    -- infMinf_uid132_fpFusedAddSubTest(LOGICAL,131)@12
    infMinf_uid132_fpFusedAddSubTest_q <= excI_siga_uid20_fpFusedAddSubTest_q and excI_sigb_uid34_fpFusedAddSubTest_q and effSub_uid45_fpFusedAddSubTest_q;

    -- excRNaNA_uid133_fpFusedAddSubTest(LOGICAL,132)@12
    excRNaNA_uid133_fpFusedAddSubTest_q <= infMinf_uid132_fpFusedAddSubTest_q or excN_siga_uid21_fpFusedAddSubTest_q or excN_sigb_uid35_fpFusedAddSubTest_q;

    -- invExcRNaNA_uid162_fpFusedAddSubTest(LOGICAL,161)@12
    invExcRNaNA_uid162_fpFusedAddSubTest_q <= not (excRNaNA_uid133_fpFusedAddSubTest_q);

    -- signRPostExc_uid163_fpFusedAddSubTest(LOGICAL,162)@12 + 1
    signRPostExc_uid163_fpFusedAddSubTest_qi <= invExcRNaNA_uid162_fpFusedAddSubTest_q and redist48_sigA_uid43_fpFusedAddSubTest_b_11_q and invAMA_uid161_fpFusedAddSubTest_q and invSignInputsZeroNoSwap_uid159_fpFusedAddSubTest_q and invSignInputsZeroSwap_uid156_fpFusedAddSubTest_q;
    signRPostExc_uid163_fpFusedAddSubTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExc_uid163_fpFusedAddSubTest_qi, xout => signRPostExc_uid163_fpFusedAddSubTest_q, clk => clk, aclr => areset );

    -- redist28_signRPostExc_uid163_fpFusedAddSubTest_q_3(DELAY,473)
    redist28_signRPostExc_uid163_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => signRPostExc_uid163_fpFusedAddSubTest_q, xout => redist28_signRPostExc_uid163_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- expRPreExcAddition_uid142_fpFusedAddSubTest(MUX,141)@13 + 1
    expRPreExcAddition_uid142_fpFusedAddSubTest_s <= redist45_effSub_uid45_fpFusedAddSubTest_q_1_q;
    expRPreExcAddition_uid142_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expRPreExcAddition_uid142_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (expRPreExcAddition_uid142_fpFusedAddSubTest_s) IS
                WHEN "0" => expRPreExcAddition_uid142_fpFusedAddSubTest_q <= expRPreExcAdd_uid117_fpFusedAddSubTest_b;
                WHEN "1" => expRPreExcAddition_uid142_fpFusedAddSubTest_q <= expRPreExcSub_uid114_fpFusedAddSubTest_b;
                WHEN OTHERS => expRPreExcAddition_uid142_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2(DELAY,477)
    redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExcAddition_uid142_fpFusedAddSubTest_q, xout => redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- redist35_excRNaNA_uid133_fpFusedAddSubTest_q_3(DELAY,480)
    redist35_excRNaNA_uid133_fpFusedAddSubTest_q_3 : dspba_delay
    GENERIC MAP ( width => 1, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaNA_uid133_fpFusedAddSubTest_q, xout => redist35_excRNaNA_uid133_fpFusedAddSubTest_q_3_q, clk => clk, aclr => areset );

    -- excRInfAdd_uid128_fpFusedAddSubTest(LOOKUP,127)@14 + 1
    excRInfAdd_uid128_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRInfVInC_uid127_fpFusedAddSubTest_q) IS
                WHEN "000000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "000110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "000111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "001101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "001110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "001111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "010011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "010100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "010111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "011111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "1";
                WHEN "100001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "100111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "101111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "110111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111000" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111001" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111010" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111011" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111100" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111101" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111110" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN "111111" => excRInfAdd_uid128_fpFusedAddSubTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRInfAdd_uid128_fpFusedAddSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- excRInfAddFull_uid129_fpFusedAddSubTest(LOGICAL,128)@15
    excRInfAddFull_uid129_fpFusedAddSubTest_q <= addIsAlsoInf_uid126_fpFusedAddSubTest_q or excRInfAdd_uid128_fpFusedAddSubTest_q;

    -- excRZeroAdd_uid121_fpFusedAddSubTest(LOOKUP,120)@14 + 1
    excRZeroAdd_uid121_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (excRZeroVInC_uid120_fpFusedAddSubTest_q) IS
                WHEN "000000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "1";
                WHEN "000100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "000111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "001111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "010111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "011111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "100111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "1";
                WHEN "101101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "101111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "1";
                WHEN "110101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "110111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111000" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111001" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111010" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111011" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111100" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "1";
                WHEN "111101" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111110" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN "111111" => excRZeroAdd_uid121_fpFusedAddSubTest_q <= "0";
                WHEN OTHERS => -- unreachable
                               excRZeroAdd_uid121_fpFusedAddSubTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- concExcAdd_uid138_fpFusedAddSubTest(BITJOIN,137)@15
    concExcAdd_uid138_fpFusedAddSubTest_q <= redist35_excRNaNA_uid133_fpFusedAddSubTest_q_3_q & excRInfAddFull_uid129_fpFusedAddSubTest_q & excRZeroAdd_uid121_fpFusedAddSubTest_q;

    -- excREncAdd_uid140_fpFusedAddSubTest(LOOKUP,139)@15
    excREncAdd_uid140_fpFusedAddSubTest_combproc: PROCESS (concExcAdd_uid138_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExcAdd_uid138_fpFusedAddSubTest_q) IS
            WHEN "000" => excREncAdd_uid140_fpFusedAddSubTest_q <= "01";
            WHEN "001" => excREncAdd_uid140_fpFusedAddSubTest_q <= "00";
            WHEN "010" => excREncAdd_uid140_fpFusedAddSubTest_q <= "10";
            WHEN "011" => excREncAdd_uid140_fpFusedAddSubTest_q <= "00";
            WHEN "100" => excREncAdd_uid140_fpFusedAddSubTest_q <= "11";
            WHEN "101" => excREncAdd_uid140_fpFusedAddSubTest_q <= "00";
            WHEN "110" => excREncAdd_uid140_fpFusedAddSubTest_q <= "00";
            WHEN "111" => excREncAdd_uid140_fpFusedAddSubTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREncAdd_uid140_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExcAdd_uid152_fpFusedAddSubTest(MUX,151)@15
    expRPostExcAdd_uid152_fpFusedAddSubTest_s <= excREncAdd_uid140_fpFusedAddSubTest_q;
    expRPostExcAdd_uid152_fpFusedAddSubTest_combproc: PROCESS (expRPostExcAdd_uid152_fpFusedAddSubTest_s, cstAllZWE_uid13_fpFusedAddSubTest_q, redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2_q, cstAllOWE_uid11_fpFusedAddSubTest_q)
    BEGIN
        CASE (expRPostExcAdd_uid152_fpFusedAddSubTest_s) IS
            WHEN "00" => expRPostExcAdd_uid152_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q;
            WHEN "01" => expRPostExcAdd_uid152_fpFusedAddSubTest_q <= redist32_expRPreExcAddition_uid142_fpFusedAddSubTest_q_2_q;
            WHEN "10" => expRPostExcAdd_uid152_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN "11" => expRPostExcAdd_uid152_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN OTHERS => expRPostExcAdd_uid152_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPreExcAddition_uid141_fpFusedAddSubTest(MUX,140)@13 + 1
    fracRPreExcAddition_uid141_fpFusedAddSubTest_s <= redist45_effSub_uid45_fpFusedAddSubTest_q_1_q;
    fracRPreExcAddition_uid141_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPreExcAddition_uid141_fpFusedAddSubTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRPreExcAddition_uid141_fpFusedAddSubTest_s) IS
                WHEN "0" => fracRPreExcAddition_uid141_fpFusedAddSubTest_q <= fracRPreExcAdd_uid116_fpFusedAddSubTest_b;
                WHEN "1" => fracRPreExcAddition_uid141_fpFusedAddSubTest_q <= fracRPreExcSub_uid113_fpFusedAddSubTest_b;
                WHEN OTHERS => fracRPreExcAddition_uid141_fpFusedAddSubTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2(DELAY,478)
    redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRPreExcAddition_uid141_fpFusedAddSubTest_q, xout => redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2_q, clk => clk, aclr => areset );

    -- fracRPostExcAdd_uid148_fpFusedAddSubTest(MUX,147)@15
    fracRPostExcAdd_uid148_fpFusedAddSubTest_s <= excREncAdd_uid140_fpFusedAddSubTest_q;
    fracRPostExcAdd_uid148_fpFusedAddSubTest_combproc: PROCESS (fracRPostExcAdd_uid148_fpFusedAddSubTest_s, cstZeroWF_uid12_fpFusedAddSubTest_q, redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2_q, oneFracRPostExc2_uid145_fpFusedAddSubTest_q)
    BEGIN
        CASE (fracRPostExcAdd_uid148_fpFusedAddSubTest_s) IS
            WHEN "00" => fracRPostExcAdd_uid148_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "01" => fracRPostExcAdd_uid148_fpFusedAddSubTest_q <= redist33_fracRPreExcAddition_uid141_fpFusedAddSubTest_q_2_q;
            WHEN "10" => fracRPostExcAdd_uid148_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "11" => fracRPostExcAdd_uid148_fpFusedAddSubTest_q <= oneFracRPostExc2_uid145_fpFusedAddSubTest_q;
            WHEN OTHERS => fracRPostExcAdd_uid148_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- RSum_uid164_fpFusedAddSubTest(BITJOIN,163)@15
    RSum_uid164_fpFusedAddSubTest_q <= redist28_signRPostExc_uid163_fpFusedAddSubTest_q_3_q & expRPostExcAdd_uid152_fpFusedAddSubTest_q & fracRPostExcAdd_uid148_fpFusedAddSubTest_q;

    -- xOut(GPOUT,4)@15
    q <= RSum_uid164_fpFusedAddSubTest_q;
    s <= RDiff_uid186_fpFusedAddSubTest_q;

END normal;
