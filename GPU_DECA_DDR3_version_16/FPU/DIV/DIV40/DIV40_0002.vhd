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

-- VHDL created from DIV40_0002
-- VHDL created on Thu Oct 20 12:06:09 2022


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

entity DIV40_0002 is
    port (
        a : in std_logic_vector(39 downto 0);  -- float40_m31
        b : in std_logic_vector(39 downto 0);  -- float40_m31
        q : out std_logic_vector(39 downto 0);  -- float40_m31
        clk : in std_logic;
        areset : in std_logic
    );
end DIV40_0002;

architecture normal of DIV40_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstBiasM1_uid6_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstBias_uid7_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal expX_uid9_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracX_uid10_fpDivTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal signX_uid11_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expY_uid12_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracY_uid13_fpDivTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal signY_uid14_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal paddingY_uid15_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal updatedY_uid16_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal fracYZero_uid15_fpDivTest_a : STD_LOGIC_VECTOR (31 downto 0);
    signal fracYZero_uid15_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYZero_uid15_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid18_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstAllZWE_uid20_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_x_uid23_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXmY_uid47_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expR_uid48_fpDivTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal yAddr_uid51_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal yPE_uid52_fpDivTest_b : STD_LOGIC_VECTOR (21 downto 0);
    signal invY_uid54_fpDivTest_in : STD_LOGIC_VECTOR (43 downto 0);
    signal invY_uid54_fpDivTest_b : STD_LOGIC_VECTOR (38 downto 0);
    signal invYO_uid55_fpDivTest_in : STD_LOGIC_VECTOR (44 downto 0);
    signal invYO_uid55_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal lOAdded_uid57_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal z4_uid60_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal oFracXZ4_uid61_fpDivTest_q : STD_LOGIC_VECTOR (36 downto 0);
    signal divValPreNormYPow2Exc_uid63_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormYPow2Exc_uid63_fpDivTest_q : STD_LOGIC_VECTOR (36 downto 0);
    signal norm_uid64_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormHigh_uid65_fpDivTest_in : STD_LOGIC_VECTOR (35 downto 0);
    signal divValPreNormHigh_uid65_fpDivTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal divValPreNormLow_uid66_fpDivTest_in : STD_LOGIC_VECTOR (34 downto 0);
    signal divValPreNormLow_uid66_fpDivTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal normFracRnd_uid67_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal normFracRnd_uid67_fpDivTest_q : STD_LOGIC_VECTOR (32 downto 0);
    signal expFracRnd_uid68_fpDivTest_q : STD_LOGIC_VECTOR (42 downto 0);
    signal zeroPaddingInAddition_uid74_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal expFracPostRnd_uid75_fpDivTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_a : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_b : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_o : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_q : STD_LOGIC_VECTOR (43 downto 0);
    signal fracXExt_uid77_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal fracPostRndF_uid79_fpDivTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal fracPostRndF_uid79_fpDivTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal fracPostRndF_uid80_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracPostRndF_uid80_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal expPostRndFR_uid81_fpDivTest_in : STD_LOGIC_VECTOR (40 downto 0);
    signal expPostRndFR_uid81_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expPostRndF_uid82_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expPostRndF_uid82_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal lOAdded_uid84_fpDivTest_q : STD_LOGIC_VECTOR (32 downto 0);
    signal lOAdded_uid87_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProdNorm_uid90_fpDivTest_in : STD_LOGIC_VECTOR (64 downto 0);
    signal qDivProdNorm_uid90_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProdFracHigh_uid91_fpDivTest_in : STD_LOGIC_VECTOR (63 downto 0);
    signal qDivProdFracHigh_uid91_fpDivTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProdFracLow_uid92_fpDivTest_in : STD_LOGIC_VECTOR (62 downto 0);
    signal qDivProdFracLow_uid92_fpDivTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProdFrac_uid93_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProdFrac_uid93_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_uid96_fpDivTest_a : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_o : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal qDivProdFracWF_uid97_fpDivTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal qDivProdLTX_opA_uid98_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal qDivProdLTX_opA_uid98_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal qDivProdLTX_opA_uid99_fpDivTest_q : STD_LOGIC_VECTOR (38 downto 0);
    signal qDivProdLTX_opB_uid100_fpDivTest_q : STD_LOGIC_VECTOR (38 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_a : STD_LOGIC_VECTOR (40 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_b : STD_LOGIC_VECTOR (40 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_o : STD_LOGIC_VECTOR (40 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal betweenFPwF_uid102_fpDivTest_in : STD_LOGIC_VECTOR (0 downto 0);
    signal betweenFPwF_uid102_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal extraUlp_uid103_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal extraUlp_uid103_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracPostRndFT_uid104_fpDivTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_a : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_o : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal fracPostRndFPostUlp_uid106_fpDivTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal fracPostRndFPostUlp_uid106_fpDivTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal fracRPreExc_uid107_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExc_uid107_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal ovfIncRnd_uid109_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndR_uid111_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal expFracPostRndR_uid111_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expRPreExc_uid112_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExc_uid112_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal expRExt_uid114_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal expUdf_uid115_fpDivTest_a : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid115_fpDivTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid115_fpDivTest_o : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid115_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid118_fpDivTest_a : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid118_fpDivTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid118_fpDivTest_o : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid118_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid119_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid119_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid121_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid122_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid122_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid123_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid124_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid125_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid126_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid127_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid129_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid130_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid132_fpDivTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid133_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oneFracRPostExc2_uid134_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal fracRPostExc_uid137_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid137_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPostExc_uid141_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid141_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invExcRNaN_uid142_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid143_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid143_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal divR_uid144_fpDivTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal os_uid149_invTables_q : STD_LOGIC_VECTOR (43 downto 0);
    signal os_uid153_invTables_q : STD_LOGIC_VECTOR (33 downto 0);
    signal os_uid157_invTables_q : STD_LOGIC_VECTOR (24 downto 0);
    signal yT1_uid166_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal rndBit_uid168_invPolyEval_q : STD_LOGIC_VECTOR (1 downto 0);
    signal cIncludingRoundingBit_uid169_invPolyEval_q : STD_LOGIC_VECTOR (26 downto 0);
    signal ts1_uid171_invPolyEval_a : STD_LOGIC_VECTOR (27 downto 0);
    signal ts1_uid171_invPolyEval_b : STD_LOGIC_VECTOR (27 downto 0);
    signal ts1_uid171_invPolyEval_o : STD_LOGIC_VECTOR (27 downto 0);
    signal ts1_uid171_invPolyEval_q : STD_LOGIC_VECTOR (27 downto 0);
    signal s1_uid172_invPolyEval_b : STD_LOGIC_VECTOR (26 downto 0);
    signal cIncludingRoundingBit_uid176_invPolyEval_q : STD_LOGIC_VECTOR (35 downto 0);
    signal ts2_uid178_invPolyEval_a : STD_LOGIC_VECTOR (36 downto 0);
    signal ts2_uid178_invPolyEval_b : STD_LOGIC_VECTOR (36 downto 0);
    signal ts2_uid178_invPolyEval_o : STD_LOGIC_VECTOR (36 downto 0);
    signal ts2_uid178_invPolyEval_q : STD_LOGIC_VECTOR (36 downto 0);
    signal s2_uid179_invPolyEval_b : STD_LOGIC_VECTOR (35 downto 0);
    signal rndBit_uid182_invPolyEval_q : STD_LOGIC_VECTOR (2 downto 0);
    signal cIncludingRoundingBit_uid183_invPolyEval_q : STD_LOGIC_VECTOR (46 downto 0);
    signal ts3_uid185_invPolyEval_a : STD_LOGIC_VECTOR (47 downto 0);
    signal ts3_uid185_invPolyEval_b : STD_LOGIC_VECTOR (47 downto 0);
    signal ts3_uid185_invPolyEval_o : STD_LOGIC_VECTOR (47 downto 0);
    signal ts3_uid185_invPolyEval_q : STD_LOGIC_VECTOR (47 downto 0);
    signal s3_uid186_invPolyEval_b : STD_LOGIC_VECTOR (46 downto 0);
    signal topRangeX_uid196_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal topRangeY_uid197_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal aboveLeftY_bottomExtension_uid215_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (13 downto 0);
    signal aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal aboveLeftY_mergedSignalTM_uid217_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (20 downto 0);
    signal rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (20 downto 0);
    signal aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (13 downto 0);
    signal aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal rightBottomX_bottomExtension_uid226_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (2 downto 0);
    signal rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal rightBottomX_mergedSignalTM_uid228_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rightBottomY_uid230_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal n1_uid233_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid234_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid235_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid236_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid239_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n0_uid240_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n1_uid241_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n0_uid242_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid249_divValPreNorm_uid59_fpDivTest_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid249_divValPreNorm_uid59_fpDivTest_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid249_divValPreNorm_uid59_fpDivTest_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid249_divValPreNorm_uid59_fpDivTest_reset : std_logic;
    signal sm0_uid249_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid250_divValPreNorm_uid59_fpDivTest_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid250_divValPreNorm_uid59_fpDivTest_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid250_divValPreNorm_uid59_fpDivTest_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid250_divValPreNorm_uid59_fpDivTest_reset : std_logic;
    signal sm0_uid250_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal sm1_uid251_divValPreNorm_uid59_fpDivTest_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid251_divValPreNorm_uid59_fpDivTest_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid251_divValPreNorm_uid59_fpDivTest_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal sm1_uid251_divValPreNorm_uid59_fpDivTest_reset : std_logic;
    signal sm1_uid251_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid252_divValPreNorm_uid59_fpDivTest_a0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid252_divValPreNorm_uid59_fpDivTest_b0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid252_divValPreNorm_uid59_fpDivTest_s1 : STD_LOGIC_VECTOR (5 downto 0);
    signal sm0_uid252_divValPreNorm_uid59_fpDivTest_reset : std_logic;
    signal sm0_uid252_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal sm1_uid253_divValPreNorm_uid59_fpDivTest_a0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm1_uid253_divValPreNorm_uid59_fpDivTest_b0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm1_uid253_divValPreNorm_uid59_fpDivTest_s1 : STD_LOGIC_VECTOR (5 downto 0);
    signal sm1_uid253_divValPreNorm_uid59_fpDivTest_reset : std_logic;
    signal sm1_uid253_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal sumAb_uid254_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (41 downto 0);
    signal lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_a : STD_LOGIC_VECTOR (42 downto 0);
    signal lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (42 downto 0);
    signal lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_o : STD_LOGIC_VECTOR (42 downto 0);
    signal lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (42 downto 0);
    signal lev1_a0_uid258_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (54 downto 0);
    signal lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_a : STD_LOGIC_VECTOR (24 downto 0);
    signal lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_o : STD_LOGIC_VECTOR (24 downto 0);
    signal lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal lev1_a1_uid262_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (36 downto 0);
    signal lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_a : STD_LOGIC_VECTOR (55 downto 0);
    signal lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (55 downto 0);
    signal lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_o : STD_LOGIC_VECTOR (55 downto 0);
    signal lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_q : STD_LOGIC_VECTOR (55 downto 0);
    signal osig_uid264_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (53 downto 0);
    signal osig_uid264_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (36 downto 0);
    signal nx_mergedSignalTM_uid268_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (17 downto 0);
    signal rightBottomX_mergedSignalTM_uid285_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rightBottomY_uid287_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (4 downto 0);
    signal n1_uid290_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid291_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid294_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n0_uid295_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n1_uid298_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal n0_uid299_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal sm0_uid304_pT1_uid167_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid304_pT1_uid167_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid304_pT1_uid167_invPolyEval_s1 : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid304_pT1_uid167_invPolyEval_reset : std_logic;
    signal sm0_uid304_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid305_pT1_uid167_invPolyEval_a0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid305_pT1_uid167_invPolyEval_b0 : STD_LOGIC_VECTOR (1 downto 0);
    signal sm0_uid305_pT1_uid167_invPolyEval_s1 : STD_LOGIC_VECTOR (4 downto 0);
    signal sm0_uid305_pT1_uid167_invPolyEval_reset : std_logic;
    signal sm0_uid305_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (3 downto 0);
    signal lowRangeA_uid306_pT1_uid167_invPolyEval_in : STD_LOGIC_VECTOR (12 downto 0);
    signal lowRangeA_uid306_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal highABits_uid307_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (20 downto 0);
    signal lev1_a0high_uid308_pT1_uid167_invPolyEval_a : STD_LOGIC_VECTOR (21 downto 0);
    signal lev1_a0high_uid308_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (21 downto 0);
    signal lev1_a0high_uid308_pT1_uid167_invPolyEval_o : STD_LOGIC_VECTOR (21 downto 0);
    signal lev1_a0high_uid308_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (21 downto 0);
    signal lev1_a0_uid309_pT1_uid167_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal osig_uid310_pT1_uid167_invPolyEval_in : STD_LOGIC_VECTOR (32 downto 0);
    signal osig_uid310_pT1_uid167_invPolyEval_b : STD_LOGIC_VECTOR (17 downto 0);
    signal nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (22 downto 0);
    signal topRangeX_uid324_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal aboveLeftY_bottomExtension_uid350_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (6 downto 0);
    signal aboveLeftY_mergedSignalTM_uid352_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal rightBottomX_bottomExtension_uid354_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (10 downto 0);
    signal rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_in : STD_LOGIC_VECTOR (5 downto 0);
    signal rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (5 downto 0);
    signal rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid359_pT2_uid174_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid359_pT2_uid174_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid359_pT2_uid174_invPolyEval_s1 : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid359_pT2_uid174_invPolyEval_reset : std_logic;
    signal sm0_uid359_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid360_pT2_uid174_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid360_pT2_uid174_invPolyEval_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid360_pT2_uid174_invPolyEval_s1 : STD_LOGIC_VECTOR (34 downto 0);
    signal sm0_uid360_pT2_uid174_invPolyEval_reset : std_logic;
    signal sm0_uid360_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm1_uid361_pT2_uid174_invPolyEval_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid361_pT2_uid174_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm1_uid361_pT2_uid174_invPolyEval_s1 : STD_LOGIC_VECTOR (34 downto 0);
    signal sm1_uid361_pT2_uid174_invPolyEval_reset : std_logic;
    signal sm1_uid361_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal lowRangeB_uid362_pT2_uid174_invPolyEval_in : STD_LOGIC_VECTOR (16 downto 0);
    signal lowRangeB_uid362_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal highBBits_uid363_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_a : STD_LOGIC_VECTOR (34 downto 0);
    signal lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (34 downto 0);
    signal lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_o : STD_LOGIC_VECTOR (34 downto 0);
    signal lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal lev1_a0_uid365_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (51 downto 0);
    signal lev2_a0_uid366_pT2_uid174_invPolyEval_a : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid366_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid366_pT2_uid174_invPolyEval_o : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid366_pT2_uid174_invPolyEval_q : STD_LOGIC_VECTOR (52 downto 0);
    signal osig_uid367_pT2_uid174_invPolyEval_in : STD_LOGIC_VECTOR (49 downto 0);
    signal osig_uid367_pT2_uid174_invPolyEval_b : STD_LOGIC_VECTOR (27 downto 0);
    signal topRangeY_uid382_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal aboveLeftY_uid404_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (18 downto 0);
    signal aboveLeftY_uid404_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal aboveLeftX_uid420_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftY_bottomExtension_uid421_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (5 downto 0);
    signal aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (1 downto 0);
    signal aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal aboveLeftY_mergedSignalTM_uid423_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftX_mergedSignalTM_uid427_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftY_uid429_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (18 downto 0);
    signal aboveLeftY_uid429_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (7 downto 0);
    signal sm0_uid433_pT3_uid181_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid433_pT3_uid181_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid433_pT3_uid181_invPolyEval_s1 : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid433_pT3_uid181_invPolyEval_reset : std_logic;
    signal sm0_uid433_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid434_pT3_uid181_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid434_pT3_uid181_invPolyEval_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid434_pT3_uid181_invPolyEval_s1 : STD_LOGIC_VECTOR (34 downto 0);
    signal sm0_uid434_pT3_uid181_invPolyEval_reset : std_logic;
    signal sm0_uid434_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm1_uid435_pT3_uid181_invPolyEval_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid435_pT3_uid181_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm1_uid435_pT3_uid181_invPolyEval_s1 : STD_LOGIC_VECTOR (34 downto 0);
    signal sm1_uid435_pT3_uid181_invPolyEval_reset : std_logic;
    signal sm1_uid435_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid436_pT3_uid181_invPolyEval_a0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm0_uid436_pT3_uid181_invPolyEval_b0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm0_uid436_pT3_uid181_invPolyEval_s1 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid436_pT3_uid181_invPolyEval_reset : std_logic;
    signal sm0_uid436_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (15 downto 0);
    signal sm1_uid437_pT3_uid181_invPolyEval_a0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm1_uid437_pT3_uid181_invPolyEval_b0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm1_uid437_pT3_uid181_invPolyEval_s1 : STD_LOGIC_VECTOR (15 downto 0);
    signal sm1_uid437_pT3_uid181_invPolyEval_reset : std_logic;
    signal sm1_uid437_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (15 downto 0);
    signal sumAb_uid438_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (49 downto 0);
    signal lowRangeB_uid439_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeB_uid439_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highBBits_uid440_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (32 downto 0);
    signal lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_a : STD_LOGIC_VECTOR (50 downto 0);
    signal lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (50 downto 0);
    signal lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_o : STD_LOGIC_VECTOR (50 downto 0);
    signal lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (50 downto 0);
    signal lev1_a0_uid442_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (51 downto 0);
    signal lowRangeA_uid443_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeA_uid443_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highABits_uid444_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (32 downto 0);
    signal lev1_a1high_uid445_pT3_uid181_invPolyEval_a : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a1high_uid445_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a1high_uid445_pT3_uid181_invPolyEval_o : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a1high_uid445_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a1_uid446_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal lev2_a0_uid447_pT3_uid181_invPolyEval_a : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid447_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid447_pT3_uid181_invPolyEval_o : STD_LOGIC_VECTOR (52 downto 0);
    signal lev2_a0_uid447_pT3_uid181_invPolyEval_q : STD_LOGIC_VECTOR (52 downto 0);
    signal osig_uid448_pT3_uid181_invPolyEval_in : STD_LOGIC_VECTOR (49 downto 0);
    signal osig_uid448_pT3_uid181_invPolyEval_b : STD_LOGIC_VECTOR (37 downto 0);
    signal qDivProd_uid89_fpDivTest_im0_a0 : STD_LOGIC_VECTOR (15 downto 0);
    signal qDivProd_uid89_fpDivTest_im0_b0 : STD_LOGIC_VECTOR (14 downto 0);
    signal qDivProd_uid89_fpDivTest_im0_s1 : STD_LOGIC_VECTOR (30 downto 0);
    signal qDivProd_uid89_fpDivTest_im0_reset : std_logic;
    signal qDivProd_uid89_fpDivTest_im0_q : STD_LOGIC_VECTOR (30 downto 0);
    signal qDivProd_uid89_fpDivTest_bs1_b : STD_LOGIC_VECTOR (14 downto 0);
    signal qDivProd_uid89_fpDivTest_bjA2_q : STD_LOGIC_VECTOR (15 downto 0);
    signal qDivProd_uid89_fpDivTest_bs3_b : STD_LOGIC_VECTOR (13 downto 0);
    signal qDivProd_uid89_fpDivTest_bjB4_q : STD_LOGIC_VECTOR (14 downto 0);
    signal qDivProd_uid89_fpDivTest_im5_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_im5_b0 : STD_LOGIC_VECTOR (14 downto 0);
    signal qDivProd_uid89_fpDivTest_im5_s1 : STD_LOGIC_VECTOR (32 downto 0);
    signal qDivProd_uid89_fpDivTest_im5_reset : std_logic;
    signal qDivProd_uid89_fpDivTest_im5_q : STD_LOGIC_VECTOR (32 downto 0);
    signal qDivProd_uid89_fpDivTest_bs6_b : STD_LOGIC_VECTOR (14 downto 0);
    signal qDivProd_uid89_fpDivTest_bs7_in : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_bs7_b : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_im8_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_im8_b0 : STD_LOGIC_VECTOR (13 downto 0);
    signal qDivProd_uid89_fpDivTest_im8_s1 : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProd_uid89_fpDivTest_im8_reset : std_logic;
    signal qDivProd_uid89_fpDivTest_im8_q : STD_LOGIC_VECTOR (31 downto 0);
    signal qDivProd_uid89_fpDivTest_bs9_in : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_bs9_b : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_bs10_b : STD_LOGIC_VECTOR (13 downto 0);
    signal qDivProd_uid89_fpDivTest_im11_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_im11_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_im11_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal qDivProd_uid89_fpDivTest_im11_reset : std_logic;
    signal qDivProd_uid89_fpDivTest_im11_q : STD_LOGIC_VECTOR (35 downto 0);
    signal qDivProd_uid89_fpDivTest_join_14_q : STD_LOGIC_VECTOR (66 downto 0);
    signal qDivProd_uid89_fpDivTest_align_15_q : STD_LOGIC_VECTOR (50 downto 0);
    signal qDivProd_uid89_fpDivTest_align_15_qint : STD_LOGIC_VECTOR (50 downto 0);
    signal qDivProd_uid89_fpDivTest_align_17_q : STD_LOGIC_VECTOR (49 downto 0);
    signal qDivProd_uid89_fpDivTest_align_17_qint : STD_LOGIC_VECTOR (49 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_0_0_a : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_0_0_b : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_0_0_o : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_0_0_q : STD_LOGIC_VECTOR (67 downto 0);
    signal memoryC0_uid146_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid146_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid146_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid146_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid146_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid146_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid147_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid147_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid147_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid147_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid147_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid147_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid148_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid148_invTables_lutmem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC0_uid148_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid148_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid148_invTables_lutmem_ir : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC0_uid148_invTables_lutmem_r : STD_LOGIC_VECTOR (7 downto 0);
    signal memoryC1_uid151_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid151_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid151_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid151_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid151_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid151_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid152_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid152_invTables_lutmem_ia : STD_LOGIC_VECTOR (15 downto 0);
    signal memoryC1_uid152_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid152_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid152_invTables_lutmem_ir : STD_LOGIC_VECTOR (15 downto 0);
    signal memoryC1_uid152_invTables_lutmem_r : STD_LOGIC_VECTOR (15 downto 0);
    signal memoryC2_uid155_invTables_lutmem_reset0 : std_logic;
    signal memoryC2_uid155_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC2_uid155_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid155_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid155_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC2_uid155_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC2_uid156_invTables_lutmem_reset0 : std_logic;
    signal memoryC2_uid156_invTables_lutmem_ia : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC2_uid156_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid156_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid156_invTables_lutmem_ir : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC2_uid156_invTables_lutmem_r : STD_LOGIC_VECTOR (6 downto 0);
    signal memoryC3_uid159_invTables_lutmem_reset0 : std_logic;
    signal memoryC3_uid159_invTables_lutmem_ia : STD_LOGIC_VECTOR (16 downto 0);
    signal memoryC3_uid159_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC3_uid159_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC3_uid159_invTables_lutmem_ir : STD_LOGIC_VECTOR (16 downto 0);
    signal memoryC3_uid159_invTables_lutmem_r : STD_LOGIC_VECTOR (16 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_UpperBits_for_b_q : STD_LOGIC_VECTOR (18 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_a : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_b : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_o : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_c : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q : STD_LOGIC_VECTOR (67 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_a : STD_LOGIC_VECTOR (2 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_b : STD_LOGIC_VECTOR (2 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_o : STD_LOGIC_VECTOR (2 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_cin : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q_q : STD_LOGIC_VECTOR (68 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_BitJoin_for_b_q : STD_LOGIC_VECTOR (67 downto 0);
    signal topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b : STD_LOGIC_VECTOR (16 downto 0);
    signal topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_c : STD_LOGIC_VECTOR (9 downto 0);
    signal lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (11 downto 0);
    signal lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (23 downto 0);
    signal lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (11 downto 0);
    signal lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (23 downto 0);
    signal topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_b : STD_LOGIC_VECTOR (16 downto 0);
    signal topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_b : STD_LOGIC_VECTOR (17 downto 0);
    signal qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal redist0_lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (11 downto 0);
    signal redist1_lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (11 downto 0);
    signal redist2_topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b_1_q : STD_LOGIC_VECTOR (16 downto 0);
    signal redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist4_qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q_1_q : STD_LOGIC_VECTOR (67 downto 0);
    signal redist5_qDivProd_uid89_fpDivTest_im11_q_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist6_qDivProd_uid89_fpDivTest_bs10_b_1_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist7_qDivProd_uid89_fpDivTest_bs9_b_1_q : STD_LOGIC_VECTOR (17 downto 0);
    signal redist8_qDivProd_uid89_fpDivTest_im8_q_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist9_qDivProd_uid89_fpDivTest_im5_q_1_q : STD_LOGIC_VECTOR (32 downto 0);
    signal redist10_qDivProd_uid89_fpDivTest_im0_q_1_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist11_osig_uid448_pT3_uid181_invPolyEval_b_1_q : STD_LOGIC_VECTOR (37 downto 0);
    signal redist12_lowRangeA_uid443_pT3_uid181_invPolyEval_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist13_lowRangeB_uid439_pT3_uid181_invPolyEval_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_aboveLeftX_uid420_pT3_uid181_invPolyEval_b_5_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist15_osig_uid367_pT2_uid174_invPolyEval_b_1_q : STD_LOGIC_VECTOR (27 downto 0);
    signal redist16_lowRangeB_uid362_pT2_uid174_invPolyEval_b_1_q : STD_LOGIC_VECTOR (16 downto 0);
    signal redist17_rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q_4_q : STD_LOGIC_VECTOR (16 downto 0);
    signal redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist19_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_5_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5_q : STD_LOGIC_VECTOR (16 downto 0);
    signal redist21_osig_uid310_pT1_uid167_invPolyEval_b_1_q : STD_LOGIC_VECTOR (17 downto 0);
    signal redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1_q : STD_LOGIC_VECTOR (36 downto 0);
    signal redist23_s2_uid179_invPolyEval_b_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist24_s1_uid172_invPolyEval_b_1_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist25_sRPostExc_uid143_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist26_excREnc_uid133_fpDivTest_q_8_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist27_ovfIncRnd_uid109_fpDivTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist28_fracPostRndFT_uid104_fpDivTest_b_1_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist29_extraUlp_uid103_fpDivTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_qDivProdLTX_opA_uid98_fpDivTest_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_qDivProdFracWF_uid97_fpDivTest_b_1_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist32_expPostRndFR_uid81_fpDivTest_b_5_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist33_expPostRndFR_uid81_fpDivTest_b_9_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist35_norm_uid64_fpDivTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_lOAdded_uid57_fpDivTest_q_4_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist37_invYO_uid55_fpDivTest_b_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist38_invYO_uid55_fpDivTest_b_12_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist39_invY_uid54_fpDivTest_b_1_q : STD_LOGIC_VECTOR (38 downto 0);
    signal redist40_yPE_uid52_fpDivTest_b_2_q : STD_LOGIC_VECTOR (21 downto 0);
    signal redist41_yPE_uid52_fpDivTest_b_6_q : STD_LOGIC_VECTOR (21 downto 0);
    signal redist42_yAddr_uid51_fpDivTest_b_3_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist43_yAddr_uid51_fpDivTest_b_8_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist44_yAddr_uid51_fpDivTest_b_13_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist45_signR_uid46_fpDivTest_q_23_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist47_fracY_uid13_fpDivTest_b_21_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist48_fracY_uid13_fpDivTest_b_22_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist50_expY_uid12_fpDivTest_b_22_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist51_expY_uid12_fpDivTest_b_27_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist53_fracX_uid10_fpDivTest_b_21_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist54_fracX_uid10_fpDivTest_b_22_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist57_expX_uid9_fpDivTest_b_22_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist58_expX_uid9_fpDivTest_b_27_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist59_expX_uid9_fpDivTest_b_29_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_reset0 : std_logic;
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ia : STD_LOGIC_VECTOR (31 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_iq : STD_LOGIC_VECTOR (31 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve : boolean;
    attribute preserve of redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i : signal is true;
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq : std_logic;
    attribute preserve of redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq : signal is true;
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_last_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist34_fracPostRndF_uid80_fpDivTest_q_7_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_outputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_reset0 : std_logic;
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_ia : STD_LOGIC_VECTOR (30 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_aa : STD_LOGIC_VECTOR (4 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_ab : STD_LOGIC_VECTOR (4 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_iq : STD_LOGIC_VECTOR (30 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_rdcnt_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i : UNSIGNED (4 downto 0);
    attribute preserve of redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i : signal is true;
    signal redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq : std_logic;
    attribute preserve of redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq : signal is true;
    signal redist46_fracY_uid13_fpDivTest_b_19_wraddr_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_mem_last_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist46_fracY_uid13_fpDivTest_b_19_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_reset0 : std_logic;
    signal redist49_expY_uid12_fpDivTest_b_20_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_aa : STD_LOGIC_VECTOR (4 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_ab : STD_LOGIC_VECTOR (4 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_rdcnt_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_rdcnt_i : UNSIGNED (4 downto 0);
    attribute preserve of redist49_expY_uid12_fpDivTest_b_20_rdcnt_i : signal is true;
    signal redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq : std_logic;
    attribute preserve of redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq : signal is true;
    signal redist49_expY_uid12_fpDivTest_b_20_wraddr_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_mem_last_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_cmp_b : STD_LOGIC_VECTOR (5 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist49_expY_uid12_fpDivTest_b_20_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_outputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_reset0 : std_logic;
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_ia : STD_LOGIC_VECTOR (30 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_aa : STD_LOGIC_VECTOR (3 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_ab : STD_LOGIC_VECTOR (3 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_iq : STD_LOGIC_VECTOR (30 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_rdcnt_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i : UNSIGNED (3 downto 0);
    attribute preserve of redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i : signal is true;
    signal redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq : std_logic;
    attribute preserve of redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq : signal is true;
    signal redist52_fracX_uid10_fpDivTest_b_16_wraddr_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_mem_last_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_cmp_b : STD_LOGIC_VECTOR (4 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist52_fracX_uid10_fpDivTest_b_16_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist53_fracX_uid10_fpDivTest_b_21_outputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_inputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_outputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_reset0 : std_logic;
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_ia : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_iq : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_rdcnt_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i : UNSIGNED (1 downto 0);
    attribute preserve of redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i : signal is true;
    signal redist55_fracX_uid10_fpDivTest_b_29_wraddr_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_mem_last_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_cmp_b : STD_LOGIC_VECTOR (2 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist55_fracX_uid10_fpDivTest_b_29_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_reset0 : std_logic;
    signal redist56_expX_uid9_fpDivTest_b_20_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_aa : STD_LOGIC_VECTOR (4 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_ab : STD_LOGIC_VECTOR (4 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_rdcnt_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_rdcnt_i : UNSIGNED (4 downto 0);
    attribute preserve of redist56_expX_uid9_fpDivTest_b_20_rdcnt_i : signal is true;
    signal redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq : std_logic;
    attribute preserve of redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq : signal is true;
    signal redist56_expX_uid9_fpDivTest_b_20_wraddr_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_mem_last_q : STD_LOGIC_VECTOR (5 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_cmp_b : STD_LOGIC_VECTOR (5 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist56_expX_uid9_fpDivTest_b_20_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- redist46_fracY_uid13_fpDivTest_b_19_notEnable(LOGICAL,579)
    redist46_fracY_uid13_fpDivTest_b_19_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist46_fracY_uid13_fpDivTest_b_19_nor(LOGICAL,580)
    redist46_fracY_uid13_fpDivTest_b_19_nor_q <= not (redist46_fracY_uid13_fpDivTest_b_19_notEnable_q or redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_q);

    -- redist46_fracY_uid13_fpDivTest_b_19_mem_last(CONSTANT,576)
    redist46_fracY_uid13_fpDivTest_b_19_mem_last_q <= "01111";

    -- redist46_fracY_uid13_fpDivTest_b_19_cmp(LOGICAL,577)
    redist46_fracY_uid13_fpDivTest_b_19_cmp_q <= "1" WHEN redist46_fracY_uid13_fpDivTest_b_19_mem_last_q = redist46_fracY_uid13_fpDivTest_b_19_rdcnt_q ELSE "0";

    -- redist46_fracY_uid13_fpDivTest_b_19_cmpReg(REG,578)
    redist46_fracY_uid13_fpDivTest_b_19_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_cmpReg_q <= STD_LOGIC_VECTOR(redist46_fracY_uid13_fpDivTest_b_19_cmp_q);
        END IF;
    END PROCESS;

    -- redist46_fracY_uid13_fpDivTest_b_19_sticky_ena(REG,581)
    redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist46_fracY_uid13_fpDivTest_b_19_nor_q = "1") THEN
                redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_q <= STD_LOGIC_VECTOR(redist46_fracY_uid13_fpDivTest_b_19_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist46_fracY_uid13_fpDivTest_b_19_enaAnd(LOGICAL,582)
    redist46_fracY_uid13_fpDivTest_b_19_enaAnd_q <= redist46_fracY_uid13_fpDivTest_b_19_sticky_ena_q and VCC_q;

    -- redist46_fracY_uid13_fpDivTest_b_19_rdcnt(COUNTER,574)
    -- low=0, high=16, step=1, init=0
    redist46_fracY_uid13_fpDivTest_b_19_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i <= TO_UNSIGNED(0, 5);
            redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i = TO_UNSIGNED(15, 5)) THEN
                redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq <= '1';
            ELSE
                redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq <= '0';
            END IF;
            IF (redist46_fracY_uid13_fpDivTest_b_19_rdcnt_eq = '1') THEN
                redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i <= redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i + 16;
            ELSE
                redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i <= redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist46_fracY_uid13_fpDivTest_b_19_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist46_fracY_uid13_fpDivTest_b_19_rdcnt_i, 5)));

    -- fracY_uid13_fpDivTest(BITSELECT,12)@0
    fracY_uid13_fpDivTest_b <= b(30 downto 0);

    -- redist46_fracY_uid13_fpDivTest_b_19_wraddr(REG,575)
    redist46_fracY_uid13_fpDivTest_b_19_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_wraddr_q <= "10000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist46_fracY_uid13_fpDivTest_b_19_wraddr_q <= STD_LOGIC_VECTOR(redist46_fracY_uid13_fpDivTest_b_19_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist46_fracY_uid13_fpDivTest_b_19_mem(DUALMEM,573)
    redist46_fracY_uid13_fpDivTest_b_19_mem_ia <= STD_LOGIC_VECTOR(fracY_uid13_fpDivTest_b);
    redist46_fracY_uid13_fpDivTest_b_19_mem_aa <= redist46_fracY_uid13_fpDivTest_b_19_wraddr_q;
    redist46_fracY_uid13_fpDivTest_b_19_mem_ab <= redist46_fracY_uid13_fpDivTest_b_19_rdcnt_q;
    redist46_fracY_uid13_fpDivTest_b_19_mem_reset0 <= areset;
    redist46_fracY_uid13_fpDivTest_b_19_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 31,
        widthad_a => 5,
        numwords_a => 17,
        width_b => 31,
        widthad_b => 5,
        numwords_b => 17,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist46_fracY_uid13_fpDivTest_b_19_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist46_fracY_uid13_fpDivTest_b_19_mem_reset0,
        clock1 => clk,
        address_a => redist46_fracY_uid13_fpDivTest_b_19_mem_aa,
        data_a => redist46_fracY_uid13_fpDivTest_b_19_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist46_fracY_uid13_fpDivTest_b_19_mem_ab,
        q_b => redist46_fracY_uid13_fpDivTest_b_19_mem_iq
    );
    redist46_fracY_uid13_fpDivTest_b_19_mem_q <= redist46_fracY_uid13_fpDivTest_b_19_mem_iq(30 downto 0);

    -- redist46_fracY_uid13_fpDivTest_b_19_outputreg(DELAY,572)
    redist46_fracY_uid13_fpDivTest_b_19_outputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist46_fracY_uid13_fpDivTest_b_19_mem_q, xout => redist46_fracY_uid13_fpDivTest_b_19_outputreg_q, clk => clk, aclr => areset );

    -- redist47_fracY_uid13_fpDivTest_b_21(DELAY,549)
    redist47_fracY_uid13_fpDivTest_b_21 : dspba_delay
    GENERIC MAP ( width => 31, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist46_fracY_uid13_fpDivTest_b_19_outputreg_q, xout => redist47_fracY_uid13_fpDivTest_b_21_q, clk => clk, aclr => areset );

    -- paddingY_uid15_fpDivTest(CONSTANT,14)
    paddingY_uid15_fpDivTest_q <= "0000000000000000000000000000000";

    -- fracXIsZero_uid39_fpDivTest(LOGICAL,38)@21 + 1
    fracXIsZero_uid39_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = redist47_fracY_uid13_fpDivTest_b_21_q ELSE "0";
    fracXIsZero_uid39_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_qi, xout => fracXIsZero_uid39_fpDivTest_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid18_fpDivTest(CONSTANT,17)
    cstAllOWE_uid18_fpDivTest_q <= "11111111";

    -- redist49_expY_uid12_fpDivTest_b_20_notEnable(LOGICAL,589)
    redist49_expY_uid12_fpDivTest_b_20_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist49_expY_uid12_fpDivTest_b_20_nor(LOGICAL,590)
    redist49_expY_uid12_fpDivTest_b_20_nor_q <= not (redist49_expY_uid12_fpDivTest_b_20_notEnable_q or redist49_expY_uid12_fpDivTest_b_20_sticky_ena_q);

    -- redist49_expY_uid12_fpDivTest_b_20_mem_last(CONSTANT,586)
    redist49_expY_uid12_fpDivTest_b_20_mem_last_q <= "010001";

    -- redist49_expY_uid12_fpDivTest_b_20_cmp(LOGICAL,587)
    redist49_expY_uid12_fpDivTest_b_20_cmp_b <= STD_LOGIC_VECTOR("0" & redist49_expY_uid12_fpDivTest_b_20_rdcnt_q);
    redist49_expY_uid12_fpDivTest_b_20_cmp_q <= "1" WHEN redist49_expY_uid12_fpDivTest_b_20_mem_last_q = redist49_expY_uid12_fpDivTest_b_20_cmp_b ELSE "0";

    -- redist49_expY_uid12_fpDivTest_b_20_cmpReg(REG,588)
    redist49_expY_uid12_fpDivTest_b_20_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_cmpReg_q <= STD_LOGIC_VECTOR(redist49_expY_uid12_fpDivTest_b_20_cmp_q);
        END IF;
    END PROCESS;

    -- redist49_expY_uid12_fpDivTest_b_20_sticky_ena(REG,591)
    redist49_expY_uid12_fpDivTest_b_20_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist49_expY_uid12_fpDivTest_b_20_nor_q = "1") THEN
                redist49_expY_uid12_fpDivTest_b_20_sticky_ena_q <= STD_LOGIC_VECTOR(redist49_expY_uid12_fpDivTest_b_20_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist49_expY_uid12_fpDivTest_b_20_enaAnd(LOGICAL,592)
    redist49_expY_uid12_fpDivTest_b_20_enaAnd_q <= redist49_expY_uid12_fpDivTest_b_20_sticky_ena_q and VCC_q;

    -- redist49_expY_uid12_fpDivTest_b_20_rdcnt(COUNTER,584)
    -- low=0, high=18, step=1, init=0
    redist49_expY_uid12_fpDivTest_b_20_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_rdcnt_i <= TO_UNSIGNED(0, 5);
            redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist49_expY_uid12_fpDivTest_b_20_rdcnt_i = TO_UNSIGNED(17, 5)) THEN
                redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq <= '1';
            ELSE
                redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq <= '0';
            END IF;
            IF (redist49_expY_uid12_fpDivTest_b_20_rdcnt_eq = '1') THEN
                redist49_expY_uid12_fpDivTest_b_20_rdcnt_i <= redist49_expY_uid12_fpDivTest_b_20_rdcnt_i + 14;
            ELSE
                redist49_expY_uid12_fpDivTest_b_20_rdcnt_i <= redist49_expY_uid12_fpDivTest_b_20_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist49_expY_uid12_fpDivTest_b_20_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist49_expY_uid12_fpDivTest_b_20_rdcnt_i, 5)));

    -- expY_uid12_fpDivTest(BITSELECT,11)@0
    expY_uid12_fpDivTest_b <= b(38 downto 31);

    -- redist49_expY_uid12_fpDivTest_b_20_wraddr(REG,585)
    redist49_expY_uid12_fpDivTest_b_20_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_wraddr_q <= "10010";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist49_expY_uid12_fpDivTest_b_20_wraddr_q <= STD_LOGIC_VECTOR(redist49_expY_uid12_fpDivTest_b_20_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist49_expY_uid12_fpDivTest_b_20_mem(DUALMEM,583)
    redist49_expY_uid12_fpDivTest_b_20_mem_ia <= STD_LOGIC_VECTOR(expY_uid12_fpDivTest_b);
    redist49_expY_uid12_fpDivTest_b_20_mem_aa <= redist49_expY_uid12_fpDivTest_b_20_wraddr_q;
    redist49_expY_uid12_fpDivTest_b_20_mem_ab <= redist49_expY_uid12_fpDivTest_b_20_rdcnt_q;
    redist49_expY_uid12_fpDivTest_b_20_mem_reset0 <= areset;
    redist49_expY_uid12_fpDivTest_b_20_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 5,
        numwords_a => 19,
        width_b => 8,
        widthad_b => 5,
        numwords_b => 19,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist49_expY_uid12_fpDivTest_b_20_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist49_expY_uid12_fpDivTest_b_20_mem_reset0,
        clock1 => clk,
        address_a => redist49_expY_uid12_fpDivTest_b_20_mem_aa,
        data_a => redist49_expY_uid12_fpDivTest_b_20_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist49_expY_uid12_fpDivTest_b_20_mem_ab,
        q_b => redist49_expY_uid12_fpDivTest_b_20_mem_iq
    );
    redist49_expY_uid12_fpDivTest_b_20_mem_q <= redist49_expY_uid12_fpDivTest_b_20_mem_iq(7 downto 0);

    -- redist50_expY_uid12_fpDivTest_b_22(DELAY,552)
    redist50_expY_uid12_fpDivTest_b_22 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist49_expY_uid12_fpDivTest_b_20_mem_q, xout => redist50_expY_uid12_fpDivTest_b_22_q, clk => clk, aclr => areset );

    -- expXIsMax_uid38_fpDivTest(LOGICAL,37)@22
    expXIsMax_uid38_fpDivTest_q <= "1" WHEN redist50_expY_uid12_fpDivTest_b_22_q = cstAllOWE_uid18_fpDivTest_q ELSE "0";

    -- excI_y_uid41_fpDivTest(LOGICAL,40)@22
    excI_y_uid41_fpDivTest_q <= expXIsMax_uid38_fpDivTest_q and fracXIsZero_uid39_fpDivTest_q;

    -- redist52_fracX_uid10_fpDivTest_b_16_notEnable(LOGICAL,600)
    redist52_fracX_uid10_fpDivTest_b_16_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist52_fracX_uid10_fpDivTest_b_16_nor(LOGICAL,601)
    redist52_fracX_uid10_fpDivTest_b_16_nor_q <= not (redist52_fracX_uid10_fpDivTest_b_16_notEnable_q or redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_q);

    -- redist52_fracX_uid10_fpDivTest_b_16_mem_last(CONSTANT,597)
    redist52_fracX_uid10_fpDivTest_b_16_mem_last_q <= "01100";

    -- redist52_fracX_uid10_fpDivTest_b_16_cmp(LOGICAL,598)
    redist52_fracX_uid10_fpDivTest_b_16_cmp_b <= STD_LOGIC_VECTOR("0" & redist52_fracX_uid10_fpDivTest_b_16_rdcnt_q);
    redist52_fracX_uid10_fpDivTest_b_16_cmp_q <= "1" WHEN redist52_fracX_uid10_fpDivTest_b_16_mem_last_q = redist52_fracX_uid10_fpDivTest_b_16_cmp_b ELSE "0";

    -- redist52_fracX_uid10_fpDivTest_b_16_cmpReg(REG,599)
    redist52_fracX_uid10_fpDivTest_b_16_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_cmpReg_q <= STD_LOGIC_VECTOR(redist52_fracX_uid10_fpDivTest_b_16_cmp_q);
        END IF;
    END PROCESS;

    -- redist52_fracX_uid10_fpDivTest_b_16_sticky_ena(REG,602)
    redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist52_fracX_uid10_fpDivTest_b_16_nor_q = "1") THEN
                redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_q <= STD_LOGIC_VECTOR(redist52_fracX_uid10_fpDivTest_b_16_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist52_fracX_uid10_fpDivTest_b_16_enaAnd(LOGICAL,603)
    redist52_fracX_uid10_fpDivTest_b_16_enaAnd_q <= redist52_fracX_uid10_fpDivTest_b_16_sticky_ena_q and VCC_q;

    -- redist52_fracX_uid10_fpDivTest_b_16_rdcnt(COUNTER,595)
    -- low=0, high=13, step=1, init=0
    redist52_fracX_uid10_fpDivTest_b_16_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i <= TO_UNSIGNED(0, 4);
            redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i = TO_UNSIGNED(12, 4)) THEN
                redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq <= '1';
            ELSE
                redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq <= '0';
            END IF;
            IF (redist52_fracX_uid10_fpDivTest_b_16_rdcnt_eq = '1') THEN
                redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i <= redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i + 3;
            ELSE
                redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i <= redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist52_fracX_uid10_fpDivTest_b_16_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist52_fracX_uid10_fpDivTest_b_16_rdcnt_i, 4)));

    -- fracX_uid10_fpDivTest(BITSELECT,9)@0
    fracX_uid10_fpDivTest_b <= a(30 downto 0);

    -- redist52_fracX_uid10_fpDivTest_b_16_wraddr(REG,596)
    redist52_fracX_uid10_fpDivTest_b_16_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_wraddr_q <= "1101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist52_fracX_uid10_fpDivTest_b_16_wraddr_q <= STD_LOGIC_VECTOR(redist52_fracX_uid10_fpDivTest_b_16_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist52_fracX_uid10_fpDivTest_b_16_mem(DUALMEM,594)
    redist52_fracX_uid10_fpDivTest_b_16_mem_ia <= STD_LOGIC_VECTOR(fracX_uid10_fpDivTest_b);
    redist52_fracX_uid10_fpDivTest_b_16_mem_aa <= redist52_fracX_uid10_fpDivTest_b_16_wraddr_q;
    redist52_fracX_uid10_fpDivTest_b_16_mem_ab <= redist52_fracX_uid10_fpDivTest_b_16_rdcnt_q;
    redist52_fracX_uid10_fpDivTest_b_16_mem_reset0 <= areset;
    redist52_fracX_uid10_fpDivTest_b_16_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 31,
        widthad_a => 4,
        numwords_a => 14,
        width_b => 31,
        widthad_b => 4,
        numwords_b => 14,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist52_fracX_uid10_fpDivTest_b_16_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist52_fracX_uid10_fpDivTest_b_16_mem_reset0,
        clock1 => clk,
        address_a => redist52_fracX_uid10_fpDivTest_b_16_mem_aa,
        data_a => redist52_fracX_uid10_fpDivTest_b_16_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist52_fracX_uid10_fpDivTest_b_16_mem_ab,
        q_b => redist52_fracX_uid10_fpDivTest_b_16_mem_iq
    );
    redist52_fracX_uid10_fpDivTest_b_16_mem_q <= redist52_fracX_uid10_fpDivTest_b_16_mem_iq(30 downto 0);

    -- redist52_fracX_uid10_fpDivTest_b_16_outputreg(DELAY,593)
    redist52_fracX_uid10_fpDivTest_b_16_outputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist52_fracX_uid10_fpDivTest_b_16_mem_q, xout => redist52_fracX_uid10_fpDivTest_b_16_outputreg_q, clk => clk, aclr => areset );

    -- redist53_fracX_uid10_fpDivTest_b_21(DELAY,555)
    redist53_fracX_uid10_fpDivTest_b_21 : dspba_delay
    GENERIC MAP ( width => 31, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist52_fracX_uid10_fpDivTest_b_16_outputreg_q, xout => redist53_fracX_uid10_fpDivTest_b_21_q, clk => clk, aclr => areset );

    -- redist53_fracX_uid10_fpDivTest_b_21_outputreg(DELAY,604)
    redist53_fracX_uid10_fpDivTest_b_21_outputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist53_fracX_uid10_fpDivTest_b_21_q, xout => redist53_fracX_uid10_fpDivTest_b_21_outputreg_q, clk => clk, aclr => areset );

    -- fracXIsZero_uid25_fpDivTest(LOGICAL,24)@21 + 1
    fracXIsZero_uid25_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = redist53_fracX_uid10_fpDivTest_b_21_outputreg_q ELSE "0";
    fracXIsZero_uid25_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_qi, xout => fracXIsZero_uid25_fpDivTest_q, clk => clk, aclr => areset );

    -- redist56_expX_uid9_fpDivTest_b_20_notEnable(LOGICAL,624)
    redist56_expX_uid9_fpDivTest_b_20_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist56_expX_uid9_fpDivTest_b_20_nor(LOGICAL,625)
    redist56_expX_uid9_fpDivTest_b_20_nor_q <= not (redist56_expX_uid9_fpDivTest_b_20_notEnable_q or redist56_expX_uid9_fpDivTest_b_20_sticky_ena_q);

    -- redist56_expX_uid9_fpDivTest_b_20_mem_last(CONSTANT,621)
    redist56_expX_uid9_fpDivTest_b_20_mem_last_q <= "010000";

    -- redist56_expX_uid9_fpDivTest_b_20_cmp(LOGICAL,622)
    redist56_expX_uid9_fpDivTest_b_20_cmp_b <= STD_LOGIC_VECTOR("0" & redist56_expX_uid9_fpDivTest_b_20_rdcnt_q);
    redist56_expX_uid9_fpDivTest_b_20_cmp_q <= "1" WHEN redist56_expX_uid9_fpDivTest_b_20_mem_last_q = redist56_expX_uid9_fpDivTest_b_20_cmp_b ELSE "0";

    -- redist56_expX_uid9_fpDivTest_b_20_cmpReg(REG,623)
    redist56_expX_uid9_fpDivTest_b_20_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_cmpReg_q <= STD_LOGIC_VECTOR(redist56_expX_uid9_fpDivTest_b_20_cmp_q);
        END IF;
    END PROCESS;

    -- redist56_expX_uid9_fpDivTest_b_20_sticky_ena(REG,626)
    redist56_expX_uid9_fpDivTest_b_20_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist56_expX_uid9_fpDivTest_b_20_nor_q = "1") THEN
                redist56_expX_uid9_fpDivTest_b_20_sticky_ena_q <= STD_LOGIC_VECTOR(redist56_expX_uid9_fpDivTest_b_20_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist56_expX_uid9_fpDivTest_b_20_enaAnd(LOGICAL,627)
    redist56_expX_uid9_fpDivTest_b_20_enaAnd_q <= redist56_expX_uid9_fpDivTest_b_20_sticky_ena_q and VCC_q;

    -- redist56_expX_uid9_fpDivTest_b_20_rdcnt(COUNTER,619)
    -- low=0, high=17, step=1, init=0
    redist56_expX_uid9_fpDivTest_b_20_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_rdcnt_i <= TO_UNSIGNED(0, 5);
            redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist56_expX_uid9_fpDivTest_b_20_rdcnt_i = TO_UNSIGNED(16, 5)) THEN
                redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq <= '1';
            ELSE
                redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq <= '0';
            END IF;
            IF (redist56_expX_uid9_fpDivTest_b_20_rdcnt_eq = '1') THEN
                redist56_expX_uid9_fpDivTest_b_20_rdcnt_i <= redist56_expX_uid9_fpDivTest_b_20_rdcnt_i + 15;
            ELSE
                redist56_expX_uid9_fpDivTest_b_20_rdcnt_i <= redist56_expX_uid9_fpDivTest_b_20_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist56_expX_uid9_fpDivTest_b_20_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist56_expX_uid9_fpDivTest_b_20_rdcnt_i, 5)));

    -- expX_uid9_fpDivTest(BITSELECT,8)@0
    expX_uid9_fpDivTest_b <= a(38 downto 31);

    -- redist56_expX_uid9_fpDivTest_b_20_wraddr(REG,620)
    redist56_expX_uid9_fpDivTest_b_20_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_wraddr_q <= "10001";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist56_expX_uid9_fpDivTest_b_20_wraddr_q <= STD_LOGIC_VECTOR(redist56_expX_uid9_fpDivTest_b_20_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist56_expX_uid9_fpDivTest_b_20_mem(DUALMEM,618)
    redist56_expX_uid9_fpDivTest_b_20_mem_ia <= STD_LOGIC_VECTOR(expX_uid9_fpDivTest_b);
    redist56_expX_uid9_fpDivTest_b_20_mem_aa <= redist56_expX_uid9_fpDivTest_b_20_wraddr_q;
    redist56_expX_uid9_fpDivTest_b_20_mem_ab <= redist56_expX_uid9_fpDivTest_b_20_rdcnt_q;
    redist56_expX_uid9_fpDivTest_b_20_mem_reset0 <= areset;
    redist56_expX_uid9_fpDivTest_b_20_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 5,
        numwords_a => 18,
        width_b => 8,
        widthad_b => 5,
        numwords_b => 18,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist56_expX_uid9_fpDivTest_b_20_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist56_expX_uid9_fpDivTest_b_20_mem_reset0,
        clock1 => clk,
        address_a => redist56_expX_uid9_fpDivTest_b_20_mem_aa,
        data_a => redist56_expX_uid9_fpDivTest_b_20_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist56_expX_uid9_fpDivTest_b_20_mem_ab,
        q_b => redist56_expX_uid9_fpDivTest_b_20_mem_iq
    );
    redist56_expX_uid9_fpDivTest_b_20_mem_q <= redist56_expX_uid9_fpDivTest_b_20_mem_iq(7 downto 0);

    -- redist56_expX_uid9_fpDivTest_b_20_outputreg(DELAY,617)
    redist56_expX_uid9_fpDivTest_b_20_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist56_expX_uid9_fpDivTest_b_20_mem_q, xout => redist56_expX_uid9_fpDivTest_b_20_outputreg_q, clk => clk, aclr => areset );

    -- redist57_expX_uid9_fpDivTest_b_22(DELAY,559)
    redist57_expX_uid9_fpDivTest_b_22 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist56_expX_uid9_fpDivTest_b_20_outputreg_q, xout => redist57_expX_uid9_fpDivTest_b_22_q, clk => clk, aclr => areset );

    -- expXIsMax_uid24_fpDivTest(LOGICAL,23)@22
    expXIsMax_uid24_fpDivTest_q <= "1" WHEN redist57_expX_uid9_fpDivTest_b_22_q = cstAllOWE_uid18_fpDivTest_q ELSE "0";

    -- excI_x_uid27_fpDivTest(LOGICAL,26)@22
    excI_x_uid27_fpDivTest_q <= expXIsMax_uid24_fpDivTest_q and fracXIsZero_uid25_fpDivTest_q;

    -- excXIYI_uid130_fpDivTest(LOGICAL,129)@22
    excXIYI_uid130_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excI_y_uid41_fpDivTest_q;

    -- fracXIsNotZero_uid40_fpDivTest(LOGICAL,39)@22
    fracXIsNotZero_uid40_fpDivTest_q <= not (fracXIsZero_uid39_fpDivTest_q);

    -- excN_y_uid42_fpDivTest(LOGICAL,41)@22
    excN_y_uid42_fpDivTest_q <= expXIsMax_uid38_fpDivTest_q and fracXIsNotZero_uid40_fpDivTest_q;

    -- fracXIsNotZero_uid26_fpDivTest(LOGICAL,25)@22
    fracXIsNotZero_uid26_fpDivTest_q <= not (fracXIsZero_uid25_fpDivTest_q);

    -- excN_x_uid28_fpDivTest(LOGICAL,27)@22
    excN_x_uid28_fpDivTest_q <= expXIsMax_uid24_fpDivTest_q and fracXIsNotZero_uid26_fpDivTest_q;

    -- cstAllZWE_uid20_fpDivTest(CONSTANT,19)
    cstAllZWE_uid20_fpDivTest_q <= "00000000";

    -- excZ_y_uid37_fpDivTest(LOGICAL,36)@22
    excZ_y_uid37_fpDivTest_q <= "1" WHEN redist50_expY_uid12_fpDivTest_b_22_q = cstAllZWE_uid20_fpDivTest_q ELSE "0";

    -- excZ_x_uid23_fpDivTest(LOGICAL,22)@22
    excZ_x_uid23_fpDivTest_q <= "1" WHEN redist57_expX_uid9_fpDivTest_b_22_q = cstAllZWE_uid20_fpDivTest_q ELSE "0";

    -- excXZYZ_uid129_fpDivTest(LOGICAL,128)@22
    excXZYZ_uid129_fpDivTest_q <= excZ_x_uid23_fpDivTest_q and excZ_y_uid37_fpDivTest_q;

    -- excRNaN_uid131_fpDivTest(LOGICAL,130)@22 + 1
    excRNaN_uid131_fpDivTest_qi <= excXZYZ_uid129_fpDivTest_q or excN_x_uid28_fpDivTest_q or excN_y_uid42_fpDivTest_q or excXIYI_uid130_fpDivTest_q;
    excRNaN_uid131_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaN_uid131_fpDivTest_qi, xout => excRNaN_uid131_fpDivTest_q, clk => clk, aclr => areset );

    -- invExcRNaN_uid142_fpDivTest(LOGICAL,141)@23
    invExcRNaN_uid142_fpDivTest_q <= not (excRNaN_uid131_fpDivTest_q);

    -- signY_uid14_fpDivTest(BITSELECT,13)@0
    signY_uid14_fpDivTest_b <= STD_LOGIC_VECTOR(b(39 downto 39));

    -- signX_uid11_fpDivTest(BITSELECT,10)@0
    signX_uid11_fpDivTest_b <= STD_LOGIC_VECTOR(a(39 downto 39));

    -- signR_uid46_fpDivTest(LOGICAL,45)@0 + 1
    signR_uid46_fpDivTest_qi <= signX_uid11_fpDivTest_b xor signY_uid14_fpDivTest_b;
    signR_uid46_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_qi, xout => signR_uid46_fpDivTest_q, clk => clk, aclr => areset );

    -- redist45_signR_uid46_fpDivTest_q_23(DELAY,547)
    redist45_signR_uid46_fpDivTest_q_23 : dspba_delay
    GENERIC MAP ( width => 1, depth => 22, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_q, xout => redist45_signR_uid46_fpDivTest_q_23_q, clk => clk, aclr => areset );

    -- sRPostExc_uid143_fpDivTest(LOGICAL,142)@23 + 1
    sRPostExc_uid143_fpDivTest_qi <= redist45_signR_uid46_fpDivTest_q_23_q and invExcRNaN_uid142_fpDivTest_q;
    sRPostExc_uid143_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sRPostExc_uid143_fpDivTest_qi, xout => sRPostExc_uid143_fpDivTest_q, clk => clk, aclr => areset );

    -- redist25_sRPostExc_uid143_fpDivTest_q_8(DELAY,527)
    redist25_sRPostExc_uid143_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => sRPostExc_uid143_fpDivTest_q, xout => redist25_sRPostExc_uid143_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_notEnable(LOGICAL,568)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_nor(LOGICAL,569)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_nor_q <= not (redist34_fracPostRndF_uid80_fpDivTest_q_7_notEnable_q or redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_q);

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_last(CONSTANT,565)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_last_q <= "0100";

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp(LOGICAL,566)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_b <= STD_LOGIC_VECTOR("0" & redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_q);
    redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_q <= "1" WHEN redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_last_q = redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_b ELSE "0";

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg(REG,567)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg_q <= STD_LOGIC_VECTOR(redist34_fracPostRndF_uid80_fpDivTest_q_7_cmp_q);
        END IF;
    END PROCESS;

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena(REG,570)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist34_fracPostRndF_uid80_fpDivTest_q_7_nor_q = "1") THEN
                redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_q <= STD_LOGIC_VECTOR(redist34_fracPostRndF_uid80_fpDivTest_q_7_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_enaAnd(LOGICAL,571)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_enaAnd_q <= redist34_fracPostRndF_uid80_fpDivTest_q_7_sticky_ena_q and VCC_q;

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt(COUNTER,563)
    -- low=0, high=5, step=1, init=0
    redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i <= TO_UNSIGNED(0, 3);
            redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i = TO_UNSIGNED(4, 3)) THEN
                redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq <= '1';
            ELSE
                redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq <= '0';
            END IF;
            IF (redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_eq = '1') THEN
                redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i <= redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i + 3;
            ELSE
                redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i <= redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_i, 3)));

    -- redist54_fracX_uid10_fpDivTest_b_22(DELAY,556)
    redist54_fracX_uid10_fpDivTest_b_22 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist53_fracX_uid10_fpDivTest_b_21_outputreg_q, xout => redist54_fracX_uid10_fpDivTest_b_22_q, clk => clk, aclr => areset );

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- fracXExt_uid77_fpDivTest(BITJOIN,76)@22
    fracXExt_uid77_fpDivTest_q <= redist54_fracX_uid10_fpDivTest_b_22_q & GND_q;

    -- lOAdded_uid57_fpDivTest(BITJOIN,56)@16
    lOAdded_uid57_fpDivTest_q <= VCC_q & redist52_fracX_uid10_fpDivTest_b_16_outputreg_q;

    -- redist36_lOAdded_uid57_fpDivTest_q_4(DELAY,538)
    redist36_lOAdded_uid57_fpDivTest_q_4 : dspba_delay
    GENERIC MAP ( width => 32, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => lOAdded_uid57_fpDivTest_q, xout => redist36_lOAdded_uid57_fpDivTest_q_4_q, clk => clk, aclr => areset );

    -- z4_uid60_fpDivTest(CONSTANT,59)
    z4_uid60_fpDivTest_q <= "00000";

    -- oFracXZ4_uid61_fpDivTest(BITJOIN,60)@20
    oFracXZ4_uid61_fpDivTest_q <= redist36_lOAdded_uid57_fpDivTest_q_4_q & z4_uid60_fpDivTest_q;

    -- rightBottomY_uid230_divValPreNorm_uid59_fpDivTest(BITSELECT,229)@16
    rightBottomY_uid230_divValPreNorm_uid59_fpDivTest_b <= lOAdded_uid57_fpDivTest_q(31 downto 27);

    -- n1_uid235_divValPreNorm_uid59_fpDivTest(BITSELECT,234)@16
    n1_uid235_divValPreNorm_uid59_fpDivTest_b <= rightBottomY_uid230_divValPreNorm_uid59_fpDivTest_b(4 downto 1);

    -- n1_uid241_divValPreNorm_uid59_fpDivTest(BITSELECT,240)@16
    n1_uid241_divValPreNorm_uid59_fpDivTest_b <= n1_uid235_divValPreNorm_uid59_fpDivTest_b(3 downto 1);

    -- yAddr_uid51_fpDivTest(BITSELECT,50)@0
    yAddr_uid51_fpDivTest_b <= fracY_uid13_fpDivTest_b(30 downto 22);

    -- memoryC3_uid159_invTables_lutmem(DUALMEM,477)@0 + 2
    -- in j@20000000
    memoryC3_uid159_invTables_lutmem_aa <= yAddr_uid51_fpDivTest_b;
    memoryC3_uid159_invTables_lutmem_reset0 <= areset;
    memoryC3_uid159_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 17,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC3_uid159_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC3_uid159_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC3_uid159_invTables_lutmem_aa,
        q_a => memoryC3_uid159_invTables_lutmem_ir
    );
    memoryC3_uid159_invTables_lutmem_r <= memoryC3_uid159_invTables_lutmem_ir(16 downto 0);

    -- rightBottomY_uid287_pT1_uid167_invPolyEval(BITSELECT,286)@2
    rightBottomY_uid287_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(memoryC3_uid159_invTables_lutmem_r(16 downto 12));

    -- n1_uid290_pT1_uid167_invPolyEval(BITSELECT,289)@2
    n1_uid290_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(rightBottomY_uid287_pT1_uid167_invPolyEval_b(4 downto 1));

    -- n1_uid294_pT1_uid167_invPolyEval(BITSELECT,293)@2
    n1_uid294_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(n1_uid290_pT1_uid167_invPolyEval_b(3 downto 1));

    -- n1_uid298_pT1_uid167_invPolyEval(BITSELECT,297)@2
    n1_uid298_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(n1_uid294_pT1_uid167_invPolyEval_b(2 downto 1));

    -- yPE_uid52_fpDivTest(BITSELECT,51)@0
    yPE_uid52_fpDivTest_b <= b(21 downto 0);

    -- redist40_yPE_uid52_fpDivTest_b_2(DELAY,542)
    redist40_yPE_uid52_fpDivTest_b_2 : dspba_delay
    GENERIC MAP ( width => 22, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yPE_uid52_fpDivTest_b, xout => redist40_yPE_uid52_fpDivTest_b_2_q, clk => clk, aclr => areset );

    -- yT1_uid166_invPolyEval(BITSELECT,165)@2
    yT1_uid166_invPolyEval_b <= redist40_yPE_uid52_fpDivTest_b_2_q(21 downto 5);

    -- nx_mergedSignalTM_uid268_pT1_uid167_invPolyEval(BITJOIN,267)@2
    nx_mergedSignalTM_uid268_pT1_uid167_invPolyEval_q <= GND_q & yT1_uid166_invPolyEval_b;

    -- topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select(BITSELECT,500)@2
    topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_b <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid268_pT1_uid167_invPolyEval_q(17 downto 1));
    topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_c <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid268_pT1_uid167_invPolyEval_q(0 downto 0));

    -- aboveLeftY_bottomExtension_uid215_divValPreNorm_uid59_fpDivTest(CONSTANT,214)
    aboveLeftY_bottomExtension_uid215_divValPreNorm_uid59_fpDivTest_q <= "0000";

    -- rightBottomX_mergedSignalTM_uid285_pT1_uid167_invPolyEval(BITJOIN,284)@2
    rightBottomX_mergedSignalTM_uid285_pT1_uid167_invPolyEval_q <= topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_c & aboveLeftY_bottomExtension_uid215_divValPreNorm_uid59_fpDivTest_q;

    -- n0_uid291_pT1_uid167_invPolyEval(BITSELECT,290)@2
    n0_uid291_pT1_uid167_invPolyEval_b <= rightBottomX_mergedSignalTM_uid285_pT1_uid167_invPolyEval_q(4 downto 1);

    -- n0_uid295_pT1_uid167_invPolyEval(BITSELECT,294)@2
    n0_uid295_pT1_uid167_invPolyEval_b <= n0_uid291_pT1_uid167_invPolyEval_b(3 downto 1);

    -- n0_uid299_pT1_uid167_invPolyEval(BITSELECT,298)@2
    n0_uid299_pT1_uid167_invPolyEval_b <= n0_uid295_pT1_uid167_invPolyEval_b(2 downto 1);

    -- sm0_uid305_pT1_uid167_invPolyEval(MULT,304)@2 + 2
    sm0_uid305_pT1_uid167_invPolyEval_a0 <= '0' & n0_uid299_pT1_uid167_invPolyEval_b;
    sm0_uid305_pT1_uid167_invPolyEval_b0 <= STD_LOGIC_VECTOR(n1_uid298_pT1_uid167_invPolyEval_b);
    sm0_uid305_pT1_uid167_invPolyEval_reset <= areset;
    sm0_uid305_pT1_uid167_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 3,
        lpm_widthb => 2,
        lpm_widthp => 5,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid305_pT1_uid167_invPolyEval_a0,
        datab => sm0_uid305_pT1_uid167_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid305_pT1_uid167_invPolyEval_reset,
        clock => clk,
        result => sm0_uid305_pT1_uid167_invPolyEval_s1
    );
    sm0_uid305_pT1_uid167_invPolyEval_q <= sm0_uid305_pT1_uid167_invPolyEval_s1(3 downto 0);

    -- sm0_uid304_pT1_uid167_invPolyEval(MULT,303)@2 + 2
    sm0_uid304_pT1_uid167_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_uid278_pT1_uid167_invPolyEval_merged_bit_select_b);
    sm0_uid304_pT1_uid167_invPolyEval_b0 <= STD_LOGIC_VECTOR(memoryC3_uid159_invTables_lutmem_r);
    sm0_uid304_pT1_uid167_invPolyEval_reset <= areset;
    sm0_uid304_pT1_uid167_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 17,
        lpm_widthp => 34,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid304_pT1_uid167_invPolyEval_a0,
        datab => sm0_uid304_pT1_uid167_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid304_pT1_uid167_invPolyEval_reset,
        clock => clk,
        result => sm0_uid304_pT1_uid167_invPolyEval_s1
    );
    sm0_uid304_pT1_uid167_invPolyEval_q <= sm0_uid304_pT1_uid167_invPolyEval_s1;

    -- highABits_uid307_pT1_uid167_invPolyEval(BITSELECT,306)@4
    highABits_uid307_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(sm0_uid304_pT1_uid167_invPolyEval_q(33 downto 13));

    -- lev1_a0high_uid308_pT1_uid167_invPolyEval(ADD,307)@4
    lev1_a0high_uid308_pT1_uid167_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 21 => highABits_uid307_pT1_uid167_invPolyEval_b(20)) & highABits_uid307_pT1_uid167_invPolyEval_b));
    lev1_a0high_uid308_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((21 downto 4 => sm0_uid305_pT1_uid167_invPolyEval_q(3)) & sm0_uid305_pT1_uid167_invPolyEval_q));
    lev1_a0high_uid308_pT1_uid167_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a0high_uid308_pT1_uid167_invPolyEval_a) + SIGNED(lev1_a0high_uid308_pT1_uid167_invPolyEval_b));
    lev1_a0high_uid308_pT1_uid167_invPolyEval_q <= lev1_a0high_uid308_pT1_uid167_invPolyEval_o(21 downto 0);

    -- lowRangeA_uid306_pT1_uid167_invPolyEval(BITSELECT,305)@4
    lowRangeA_uid306_pT1_uid167_invPolyEval_in <= sm0_uid304_pT1_uid167_invPolyEval_q(12 downto 0);
    lowRangeA_uid306_pT1_uid167_invPolyEval_b <= lowRangeA_uid306_pT1_uid167_invPolyEval_in(12 downto 0);

    -- lev1_a0_uid309_pT1_uid167_invPolyEval(BITJOIN,308)@4
    lev1_a0_uid309_pT1_uid167_invPolyEval_q <= lev1_a0high_uid308_pT1_uid167_invPolyEval_q & lowRangeA_uid306_pT1_uid167_invPolyEval_b;

    -- osig_uid310_pT1_uid167_invPolyEval(BITSELECT,309)@4
    osig_uid310_pT1_uid167_invPolyEval_in <= STD_LOGIC_VECTOR(lev1_a0_uid309_pT1_uid167_invPolyEval_q(32 downto 0));
    osig_uid310_pT1_uid167_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid310_pT1_uid167_invPolyEval_in(32 downto 15));

    -- redist21_osig_uid310_pT1_uid167_invPolyEval_b_1(DELAY,523)
    redist21_osig_uid310_pT1_uid167_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 18, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid310_pT1_uid167_invPolyEval_b, xout => redist21_osig_uid310_pT1_uid167_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- redist42_yAddr_uid51_fpDivTest_b_3(DELAY,544)
    redist42_yAddr_uid51_fpDivTest_b_3 : dspba_delay
    GENERIC MAP ( width => 9, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid51_fpDivTest_b, xout => redist42_yAddr_uid51_fpDivTest_b_3_q, clk => clk, aclr => areset );

    -- memoryC2_uid156_invTables_lutmem(DUALMEM,476)@3 + 2
    -- in j@20000000
    memoryC2_uid156_invTables_lutmem_aa <= redist42_yAddr_uid51_fpDivTest_b_3_q;
    memoryC2_uid156_invTables_lutmem_reset0 <= areset;
    memoryC2_uid156_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 7,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC2_uid156_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC2_uid156_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC2_uid156_invTables_lutmem_aa,
        q_a => memoryC2_uid156_invTables_lutmem_ir
    );
    memoryC2_uid156_invTables_lutmem_r <= memoryC2_uid156_invTables_lutmem_ir(6 downto 0);

    -- memoryC2_uid155_invTables_lutmem(DUALMEM,475)@3 + 2
    -- in j@20000000
    memoryC2_uid155_invTables_lutmem_aa <= redist42_yAddr_uid51_fpDivTest_b_3_q;
    memoryC2_uid155_invTables_lutmem_reset0 <= areset;
    memoryC2_uid155_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC2_uid155_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC2_uid155_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC2_uid155_invTables_lutmem_aa,
        q_a => memoryC2_uid155_invTables_lutmem_ir
    );
    memoryC2_uid155_invTables_lutmem_r <= memoryC2_uid155_invTables_lutmem_ir(17 downto 0);

    -- os_uid157_invTables(BITJOIN,156)@5
    os_uid157_invTables_q <= memoryC2_uid156_invTables_lutmem_r & memoryC2_uid155_invTables_lutmem_r;

    -- rndBit_uid168_invPolyEval(CONSTANT,167)
    rndBit_uid168_invPolyEval_q <= "01";

    -- cIncludingRoundingBit_uid169_invPolyEval(BITJOIN,168)@5
    cIncludingRoundingBit_uid169_invPolyEval_q <= os_uid157_invTables_q & rndBit_uid168_invPolyEval_q;

    -- ts1_uid171_invPolyEval(ADD,170)@5
    ts1_uid171_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 27 => cIncludingRoundingBit_uid169_invPolyEval_q(26)) & cIncludingRoundingBit_uid169_invPolyEval_q));
    ts1_uid171_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((27 downto 18 => redist21_osig_uid310_pT1_uid167_invPolyEval_b_1_q(17)) & redist21_osig_uid310_pT1_uid167_invPolyEval_b_1_q));
    ts1_uid171_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts1_uid171_invPolyEval_a) + SIGNED(ts1_uid171_invPolyEval_b));
    ts1_uid171_invPolyEval_q <= ts1_uid171_invPolyEval_o(27 downto 0);

    -- s1_uid172_invPolyEval(BITSELECT,171)@5
    s1_uid172_invPolyEval_b <= STD_LOGIC_VECTOR(ts1_uid171_invPolyEval_q(27 downto 1));

    -- redist24_s1_uid172_invPolyEval_b_1(DELAY,526)
    redist24_s1_uid172_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => s1_uid172_invPolyEval_b, xout => redist24_s1_uid172_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select(BITSELECT,497)@6
    topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b <= STD_LOGIC_VECTOR(redist24_s1_uid172_invPolyEval_b_1_q(26 downto 10));
    topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_c <= STD_LOGIC_VECTOR(redist24_s1_uid172_invPolyEval_b_1_q(9 downto 0));

    -- redist2_topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b_1(DELAY,504)
    redist2_topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 17, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b, xout => redist2_topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- redist41_yPE_uid52_fpDivTest_b_6(DELAY,543)
    redist41_yPE_uid52_fpDivTest_b_6 : dspba_delay
    GENERIC MAP ( width => 22, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist40_yPE_uid52_fpDivTest_b_2_q, xout => redist41_yPE_uid52_fpDivTest_b_6_q, clk => clk, aclr => areset );

    -- nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval(BITJOIN,313)@6
    nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval_q <= GND_q & redist41_yPE_uid52_fpDivTest_b_6_q;

    -- rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval(BITSELECT,354)@6
    rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_in <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval_q(5 downto 0));
    rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_in(5 downto 0));

    -- redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1(DELAY,520)
    redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 6, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b, xout => redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- rightBottomX_bottomExtension_uid354_pT2_uid174_invPolyEval(CONSTANT,353)
    rightBottomX_bottomExtension_uid354_pT2_uid174_invPolyEval_q <= "00000000000";

    -- rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval(BITJOIN,355)@7
    rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q <= redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1_q & rightBottomX_bottomExtension_uid354_pT2_uid174_invPolyEval_q;

    -- sm1_uid361_pT2_uid174_invPolyEval(MULT,360)@7 + 2
    sm1_uid361_pT2_uid174_invPolyEval_a0 <= '0' & rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q;
    sm1_uid361_pT2_uid174_invPolyEval_b0 <= STD_LOGIC_VECTOR(redist2_topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b_1_q);
    sm1_uid361_pT2_uid174_invPolyEval_reset <= areset;
    sm1_uid361_pT2_uid174_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 17,
        lpm_widthp => 35,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid361_pT2_uid174_invPolyEval_a0,
        datab => sm1_uid361_pT2_uid174_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm1_uid361_pT2_uid174_invPolyEval_reset,
        clock => clk,
        result => sm1_uid361_pT2_uid174_invPolyEval_s1
    );
    sm1_uid361_pT2_uid174_invPolyEval_q <= sm1_uid361_pT2_uid174_invPolyEval_s1(33 downto 0);

    -- aboveLeftY_bottomExtension_uid350_pT2_uid174_invPolyEval(CONSTANT,349)
    aboveLeftY_bottomExtension_uid350_pT2_uid174_invPolyEval_q <= "0000000";

    -- aboveLeftY_mergedSignalTM_uid352_pT2_uid174_invPolyEval(BITJOIN,351)@6
    aboveLeftY_mergedSignalTM_uid352_pT2_uid174_invPolyEval_q <= topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_c & aboveLeftY_bottomExtension_uid350_pT2_uid174_invPolyEval_q;

    -- topRangeX_uid324_pT2_uid174_invPolyEval(BITSELECT,323)@6
    topRangeX_uid324_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval_q(22 downto 6));

    -- sm0_uid360_pT2_uid174_invPolyEval(MULT,359)@6 + 2
    sm0_uid360_pT2_uid174_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_uid324_pT2_uid174_invPolyEval_b);
    sm0_uid360_pT2_uid174_invPolyEval_b0 <= '0' & aboveLeftY_mergedSignalTM_uid352_pT2_uid174_invPolyEval_q;
    sm0_uid360_pT2_uid174_invPolyEval_reset <= areset;
    sm0_uid360_pT2_uid174_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 18,
        lpm_widthp => 35,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid360_pT2_uid174_invPolyEval_a0,
        datab => sm0_uid360_pT2_uid174_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid360_pT2_uid174_invPolyEval_reset,
        clock => clk,
        result => sm0_uid360_pT2_uid174_invPolyEval_s1
    );
    sm0_uid360_pT2_uid174_invPolyEval_q <= sm0_uid360_pT2_uid174_invPolyEval_s1(33 downto 0);

    -- highBBits_uid363_pT2_uid174_invPolyEval(BITSELECT,362)@8
    highBBits_uid363_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(sm0_uid360_pT2_uid174_invPolyEval_q(33 downto 17));

    -- sm0_uid359_pT2_uid174_invPolyEval(MULT,358)@6 + 2
    sm0_uid359_pT2_uid174_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_uid324_pT2_uid174_invPolyEval_b);
    sm0_uid359_pT2_uid174_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_uid325_pT2_uid174_invPolyEval_merged_bit_select_b);
    sm0_uid359_pT2_uid174_invPolyEval_reset <= areset;
    sm0_uid359_pT2_uid174_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 17,
        lpm_widthp => 34,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid359_pT2_uid174_invPolyEval_a0,
        datab => sm0_uid359_pT2_uid174_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid359_pT2_uid174_invPolyEval_reset,
        clock => clk,
        result => sm0_uid359_pT2_uid174_invPolyEval_s1
    );
    sm0_uid359_pT2_uid174_invPolyEval_q <= sm0_uid359_pT2_uid174_invPolyEval_s1;

    -- lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval(ADD,363)@8 + 1
    lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 34 => sm0_uid359_pT2_uid174_invPolyEval_q(33)) & sm0_uid359_pT2_uid174_invPolyEval_q));
    lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 17 => highBBits_uid363_pT2_uid174_invPolyEval_b(16)) & highBBits_uid363_pT2_uid174_invPolyEval_b));
    lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_a) + SIGNED(lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_b));
        END IF;
    END PROCESS;
    lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_q <= lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_o(34 downto 0);

    -- lowRangeB_uid362_pT2_uid174_invPolyEval(BITSELECT,361)@8
    lowRangeB_uid362_pT2_uid174_invPolyEval_in <= sm0_uid360_pT2_uid174_invPolyEval_q(16 downto 0);
    lowRangeB_uid362_pT2_uid174_invPolyEval_b <= lowRangeB_uid362_pT2_uid174_invPolyEval_in(16 downto 0);

    -- redist16_lowRangeB_uid362_pT2_uid174_invPolyEval_b_1(DELAY,518)
    redist16_lowRangeB_uid362_pT2_uid174_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 17, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid362_pT2_uid174_invPolyEval_b, xout => redist16_lowRangeB_uid362_pT2_uid174_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- lev1_a0_uid365_pT2_uid174_invPolyEval(BITJOIN,364)@9
    lev1_a0_uid365_pT2_uid174_invPolyEval_q <= lev1_a0sumAHighB_uid364_pT2_uid174_invPolyEval_q & redist16_lowRangeB_uid362_pT2_uid174_invPolyEval_b_1_q;

    -- lev2_a0_uid366_pT2_uid174_invPolyEval(ADD,365)@9
    lev2_a0_uid366_pT2_uid174_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((52 downto 52 => lev1_a0_uid365_pT2_uid174_invPolyEval_q(51)) & lev1_a0_uid365_pT2_uid174_invPolyEval_q));
    lev2_a0_uid366_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((52 downto 34 => sm1_uid361_pT2_uid174_invPolyEval_q(33)) & sm1_uid361_pT2_uid174_invPolyEval_q));
    lev2_a0_uid366_pT2_uid174_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev2_a0_uid366_pT2_uid174_invPolyEval_a) + SIGNED(lev2_a0_uid366_pT2_uid174_invPolyEval_b));
    lev2_a0_uid366_pT2_uid174_invPolyEval_q <= lev2_a0_uid366_pT2_uid174_invPolyEval_o(52 downto 0);

    -- osig_uid367_pT2_uid174_invPolyEval(BITSELECT,366)@9
    osig_uid367_pT2_uid174_invPolyEval_in <= STD_LOGIC_VECTOR(lev2_a0_uid366_pT2_uid174_invPolyEval_q(49 downto 0));
    osig_uid367_pT2_uid174_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid367_pT2_uid174_invPolyEval_in(49 downto 22));

    -- redist15_osig_uid367_pT2_uid174_invPolyEval_b_1(DELAY,517)
    redist15_osig_uid367_pT2_uid174_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 28, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid367_pT2_uid174_invPolyEval_b, xout => redist15_osig_uid367_pT2_uid174_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- redist43_yAddr_uid51_fpDivTest_b_8(DELAY,545)
    redist43_yAddr_uid51_fpDivTest_b_8 : dspba_delay
    GENERIC MAP ( width => 9, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist42_yAddr_uid51_fpDivTest_b_3_q, xout => redist43_yAddr_uid51_fpDivTest_b_8_q, clk => clk, aclr => areset );

    -- memoryC1_uid152_invTables_lutmem(DUALMEM,474)@8 + 2
    -- in j@20000000
    memoryC1_uid152_invTables_lutmem_aa <= redist43_yAddr_uid51_fpDivTest_b_8_q;
    memoryC1_uid152_invTables_lutmem_reset0 <= areset;
    memoryC1_uid152_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 16,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC1_uid152_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid152_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid152_invTables_lutmem_aa,
        q_a => memoryC1_uid152_invTables_lutmem_ir
    );
    memoryC1_uid152_invTables_lutmem_r <= memoryC1_uid152_invTables_lutmem_ir(15 downto 0);

    -- memoryC1_uid151_invTables_lutmem(DUALMEM,473)@8 + 2
    -- in j@20000000
    memoryC1_uid151_invTables_lutmem_aa <= redist43_yAddr_uid51_fpDivTest_b_8_q;
    memoryC1_uid151_invTables_lutmem_reset0 <= areset;
    memoryC1_uid151_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC1_uid151_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid151_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid151_invTables_lutmem_aa,
        q_a => memoryC1_uid151_invTables_lutmem_ir
    );
    memoryC1_uid151_invTables_lutmem_r <= memoryC1_uid151_invTables_lutmem_ir(17 downto 0);

    -- os_uid153_invTables(BITJOIN,152)@10
    os_uid153_invTables_q <= memoryC1_uid152_invTables_lutmem_r & memoryC1_uid151_invTables_lutmem_r;

    -- cIncludingRoundingBit_uid176_invPolyEval(BITJOIN,175)@10
    cIncludingRoundingBit_uid176_invPolyEval_q <= os_uid153_invTables_q & rndBit_uid168_invPolyEval_q;

    -- ts2_uid178_invPolyEval(ADD,177)@10
    ts2_uid178_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((36 downto 36 => cIncludingRoundingBit_uid176_invPolyEval_q(35)) & cIncludingRoundingBit_uid176_invPolyEval_q));
    ts2_uid178_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((36 downto 28 => redist15_osig_uid367_pT2_uid174_invPolyEval_b_1_q(27)) & redist15_osig_uid367_pT2_uid174_invPolyEval_b_1_q));
    ts2_uid178_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts2_uid178_invPolyEval_a) + SIGNED(ts2_uid178_invPolyEval_b));
    ts2_uid178_invPolyEval_q <= ts2_uid178_invPolyEval_o(36 downto 0);

    -- s2_uid179_invPolyEval(BITSELECT,178)@10
    s2_uid179_invPolyEval_b <= STD_LOGIC_VECTOR(ts2_uid178_invPolyEval_q(36 downto 1));

    -- redist23_s2_uid179_invPolyEval_b_1(DELAY,525)
    redist23_s2_uid179_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 36, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => s2_uid179_invPolyEval_b, xout => redist23_s2_uid179_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval(BITSELECT,421)@11
    aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_in <= STD_LOGIC_VECTOR(redist23_s2_uid179_invPolyEval_b_1_q(1 downto 0));
    aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_in(1 downto 0));

    -- aboveLeftY_bottomExtension_uid421_pT3_uid181_invPolyEval(CONSTANT,420)
    aboveLeftY_bottomExtension_uid421_pT3_uid181_invPolyEval_q <= "000000";

    -- aboveLeftY_mergedSignalTM_uid423_pT3_uid181_invPolyEval(BITJOIN,422)@11
    aboveLeftY_mergedSignalTM_uid423_pT3_uid181_invPolyEval_q <= aboveLeftY_bottomRange_uid422_pT3_uid181_invPolyEval_b & aboveLeftY_bottomExtension_uid421_pT3_uid181_invPolyEval_q;

    -- aboveLeftX_uid420_pT3_uid181_invPolyEval(BITSELECT,419)@6
    aboveLeftX_uid420_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid314_pT2_uid174_invPolyEval_q(22 downto 15));

    -- redist14_aboveLeftX_uid420_pT3_uid181_invPolyEval_b_5(DELAY,516)
    redist14_aboveLeftX_uid420_pT3_uid181_invPolyEval_b_5 : dspba_delay
    GENERIC MAP ( width => 8, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => aboveLeftX_uid420_pT3_uid181_invPolyEval_b, xout => redist14_aboveLeftX_uid420_pT3_uid181_invPolyEval_b_5_q, clk => clk, aclr => areset );

    -- sm0_uid436_pT3_uid181_invPolyEval(MULT,435)@11 + 2
    sm0_uid436_pT3_uid181_invPolyEval_a0 <= STD_LOGIC_VECTOR(redist14_aboveLeftX_uid420_pT3_uid181_invPolyEval_b_5_q);
    sm0_uid436_pT3_uid181_invPolyEval_b0 <= '0' & aboveLeftY_mergedSignalTM_uid423_pT3_uid181_invPolyEval_q;
    sm0_uid436_pT3_uid181_invPolyEval_reset <= areset;
    sm0_uid436_pT3_uid181_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 8,
        lpm_widthb => 9,
        lpm_widthp => 17,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid436_pT3_uid181_invPolyEval_a0,
        datab => sm0_uid436_pT3_uid181_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid436_pT3_uid181_invPolyEval_reset,
        clock => clk,
        result => sm0_uid436_pT3_uid181_invPolyEval_s1
    );
    sm0_uid436_pT3_uid181_invPolyEval_q <= sm0_uid436_pT3_uid181_invPolyEval_s1(15 downto 0);

    -- topRangeY_uid382_pT3_uid181_invPolyEval(BITSELECT,381)@11
    topRangeY_uid382_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(redist23_s2_uid179_invPolyEval_b_1_q(35 downto 19));

    -- redist17_rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q_4(DELAY,519)
    redist17_rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q_4 : dspba_delay
    GENERIC MAP ( width => 17, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q, xout => redist17_rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q_4_q, clk => clk, aclr => areset );

    -- sm1_uid435_pT3_uid181_invPolyEval(MULT,434)@11 + 2
    sm1_uid435_pT3_uid181_invPolyEval_a0 <= '0' & redist17_rightBottomX_mergedSignalTM_uid356_pT2_uid174_invPolyEval_q_4_q;
    sm1_uid435_pT3_uid181_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_uid382_pT3_uid181_invPolyEval_b);
    sm1_uid435_pT3_uid181_invPolyEval_reset <= areset;
    sm1_uid435_pT3_uid181_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 17,
        lpm_widthp => 35,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid435_pT3_uid181_invPolyEval_a0,
        datab => sm1_uid435_pT3_uid181_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm1_uid435_pT3_uid181_invPolyEval_reset,
        clock => clk,
        result => sm1_uid435_pT3_uid181_invPolyEval_s1
    );
    sm1_uid435_pT3_uid181_invPolyEval_q <= sm1_uid435_pT3_uid181_invPolyEval_s1(33 downto 0);

    -- highABits_uid444_pT3_uid181_invPolyEval(BITSELECT,443)@13
    highABits_uid444_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(sm1_uid435_pT3_uid181_invPolyEval_q(33 downto 1));

    -- lev1_a1high_uid445_pT3_uid181_invPolyEval(ADD,444)@13 + 1
    lev1_a1high_uid445_pT3_uid181_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((33 downto 33 => highABits_uid444_pT3_uid181_invPolyEval_b(32)) & highABits_uid444_pT3_uid181_invPolyEval_b));
    lev1_a1high_uid445_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((33 downto 16 => sm0_uid436_pT3_uid181_invPolyEval_q(15)) & sm0_uid436_pT3_uid181_invPolyEval_q));
    lev1_a1high_uid445_pT3_uid181_invPolyEval_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            lev1_a1high_uid445_pT3_uid181_invPolyEval_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            lev1_a1high_uid445_pT3_uid181_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a1high_uid445_pT3_uid181_invPolyEval_a) + SIGNED(lev1_a1high_uid445_pT3_uid181_invPolyEval_b));
        END IF;
    END PROCESS;
    lev1_a1high_uid445_pT3_uid181_invPolyEval_q <= lev1_a1high_uid445_pT3_uid181_invPolyEval_o(33 downto 0);

    -- lowRangeA_uid443_pT3_uid181_invPolyEval(BITSELECT,442)@13
    lowRangeA_uid443_pT3_uid181_invPolyEval_in <= sm1_uid435_pT3_uid181_invPolyEval_q(0 downto 0);
    lowRangeA_uid443_pT3_uid181_invPolyEval_b <= lowRangeA_uid443_pT3_uid181_invPolyEval_in(0 downto 0);

    -- redist12_lowRangeA_uid443_pT3_uid181_invPolyEval_b_1(DELAY,514)
    redist12_lowRangeA_uid443_pT3_uid181_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeA_uid443_pT3_uid181_invPolyEval_b, xout => redist12_lowRangeA_uid443_pT3_uid181_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- lev1_a1_uid446_pT3_uid181_invPolyEval(BITJOIN,445)@14
    lev1_a1_uid446_pT3_uid181_invPolyEval_q <= lev1_a1high_uid445_pT3_uid181_invPolyEval_q & redist12_lowRangeA_uid443_pT3_uid181_invPolyEval_b_1_q;

    -- aboveLeftY_uid404_pT3_uid181_invPolyEval(BITSELECT,403)@11
    aboveLeftY_uid404_pT3_uid181_invPolyEval_in <= redist23_s2_uid179_invPolyEval_b_1_q(18 downto 0);
    aboveLeftY_uid404_pT3_uid181_invPolyEval_b <= aboveLeftY_uid404_pT3_uid181_invPolyEval_in(18 downto 2);

    -- redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5(DELAY,522)
    redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5 : dspba_delay
    GENERIC MAP ( width => 17, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => topRangeX_uid324_pT2_uid174_invPolyEval_b, xout => redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5_q, clk => clk, aclr => areset );

    -- sm0_uid434_pT3_uid181_invPolyEval(MULT,433)@11 + 2
    sm0_uid434_pT3_uid181_invPolyEval_a0 <= STD_LOGIC_VECTOR(redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5_q);
    sm0_uid434_pT3_uid181_invPolyEval_b0 <= '0' & aboveLeftY_uid404_pT3_uid181_invPolyEval_b;
    sm0_uid434_pT3_uid181_invPolyEval_reset <= areset;
    sm0_uid434_pT3_uid181_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 18,
        lpm_widthp => 35,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid434_pT3_uid181_invPolyEval_a0,
        datab => sm0_uid434_pT3_uid181_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid434_pT3_uid181_invPolyEval_reset,
        clock => clk,
        result => sm0_uid434_pT3_uid181_invPolyEval_s1
    );
    sm0_uid434_pT3_uid181_invPolyEval_q <= sm0_uid434_pT3_uid181_invPolyEval_s1(33 downto 0);

    -- highBBits_uid440_pT3_uid181_invPolyEval(BITSELECT,439)@13
    highBBits_uid440_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(sm0_uid434_pT3_uid181_invPolyEval_q(33 downto 1));

    -- sm0_uid433_pT3_uid181_invPolyEval(MULT,432)@11 + 2
    sm0_uid433_pT3_uid181_invPolyEval_a0 <= STD_LOGIC_VECTOR(redist20_topRangeX_uid324_pT2_uid174_invPolyEval_b_5_q);
    sm0_uid433_pT3_uid181_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_uid382_pT3_uid181_invPolyEval_b);
    sm0_uid433_pT3_uid181_invPolyEval_reset <= areset;
    sm0_uid433_pT3_uid181_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 17,
        lpm_widthp => 34,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid433_pT3_uid181_invPolyEval_a0,
        datab => sm0_uid433_pT3_uid181_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid433_pT3_uid181_invPolyEval_reset,
        clock => clk,
        result => sm0_uid433_pT3_uid181_invPolyEval_s1
    );
    sm0_uid433_pT3_uid181_invPolyEval_q <= sm0_uid433_pT3_uid181_invPolyEval_s1;

    -- aboveLeftY_uid429_pT3_uid181_invPolyEval(BITSELECT,428)@11
    aboveLeftY_uid429_pT3_uid181_invPolyEval_in <= redist23_s2_uid179_invPolyEval_b_1_q(18 downto 0);
    aboveLeftY_uid429_pT3_uid181_invPolyEval_b <= aboveLeftY_uid429_pT3_uid181_invPolyEval_in(18 downto 11);

    -- redist19_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_5(DELAY,521)
    redist19_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_5 : dspba_delay
    GENERIC MAP ( width => 6, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist18_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_1_q, xout => redist19_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_5_q, clk => clk, aclr => areset );

    -- aboveLeftX_mergedSignalTM_uid427_pT3_uid181_invPolyEval(BITJOIN,426)@11
    aboveLeftX_mergedSignalTM_uid427_pT3_uid181_invPolyEval_q <= redist19_rightBottomX_bottomRange_uid355_pT2_uid174_invPolyEval_b_5_q & rightBottomX_bottomExtension_uid226_divValPreNorm_uid59_fpDivTest_q;

    -- sm1_uid437_pT3_uid181_invPolyEval(MULT,436)@11 + 2
    sm1_uid437_pT3_uid181_invPolyEval_a0 <= aboveLeftX_mergedSignalTM_uid427_pT3_uid181_invPolyEval_q;
    sm1_uid437_pT3_uid181_invPolyEval_b0 <= aboveLeftY_uid429_pT3_uid181_invPolyEval_b;
    sm1_uid437_pT3_uid181_invPolyEval_reset <= areset;
    sm1_uid437_pT3_uid181_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 8,
        lpm_widthb => 8,
        lpm_widthp => 16,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid437_pT3_uid181_invPolyEval_a0,
        datab => sm1_uid437_pT3_uid181_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm1_uid437_pT3_uid181_invPolyEval_reset,
        clock => clk,
        result => sm1_uid437_pT3_uid181_invPolyEval_s1
    );
    sm1_uid437_pT3_uid181_invPolyEval_q <= sm1_uid437_pT3_uid181_invPolyEval_s1;

    -- sumAb_uid438_pT3_uid181_invPolyEval(BITJOIN,437)@13
    sumAb_uid438_pT3_uid181_invPolyEval_q <= sm0_uid433_pT3_uid181_invPolyEval_q & sm1_uid437_pT3_uid181_invPolyEval_q;

    -- lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval(ADD,440)@13 + 1
    lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((50 downto 50 => sumAb_uid438_pT3_uid181_invPolyEval_q(49)) & sumAb_uid438_pT3_uid181_invPolyEval_q));
    lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((50 downto 33 => highBBits_uid440_pT3_uid181_invPolyEval_b(32)) & highBBits_uid440_pT3_uid181_invPolyEval_b));
    lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_a) + SIGNED(lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_b));
        END IF;
    END PROCESS;
    lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_q <= lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_o(50 downto 0);

    -- lowRangeB_uid439_pT3_uid181_invPolyEval(BITSELECT,438)@13
    lowRangeB_uid439_pT3_uid181_invPolyEval_in <= sm0_uid434_pT3_uid181_invPolyEval_q(0 downto 0);
    lowRangeB_uid439_pT3_uid181_invPolyEval_b <= lowRangeB_uid439_pT3_uid181_invPolyEval_in(0 downto 0);

    -- redist13_lowRangeB_uid439_pT3_uid181_invPolyEval_b_1(DELAY,515)
    redist13_lowRangeB_uid439_pT3_uid181_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid439_pT3_uid181_invPolyEval_b, xout => redist13_lowRangeB_uid439_pT3_uid181_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- lev1_a0_uid442_pT3_uid181_invPolyEval(BITJOIN,441)@14
    lev1_a0_uid442_pT3_uid181_invPolyEval_q <= lev1_a0sumAHighB_uid441_pT3_uid181_invPolyEval_q & redist13_lowRangeB_uid439_pT3_uid181_invPolyEval_b_1_q;

    -- lev2_a0_uid447_pT3_uid181_invPolyEval(ADD,446)@14
    lev2_a0_uid447_pT3_uid181_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((52 downto 52 => lev1_a0_uid442_pT3_uid181_invPolyEval_q(51)) & lev1_a0_uid442_pT3_uid181_invPolyEval_q));
    lev2_a0_uid447_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((52 downto 35 => lev1_a1_uid446_pT3_uid181_invPolyEval_q(34)) & lev1_a1_uid446_pT3_uid181_invPolyEval_q));
    lev2_a0_uid447_pT3_uid181_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev2_a0_uid447_pT3_uid181_invPolyEval_a) + SIGNED(lev2_a0_uid447_pT3_uid181_invPolyEval_b));
    lev2_a0_uid447_pT3_uid181_invPolyEval_q <= lev2_a0_uid447_pT3_uid181_invPolyEval_o(52 downto 0);

    -- osig_uid448_pT3_uid181_invPolyEval(BITSELECT,447)@14
    osig_uid448_pT3_uid181_invPolyEval_in <= STD_LOGIC_VECTOR(lev2_a0_uid447_pT3_uid181_invPolyEval_q(49 downto 0));
    osig_uid448_pT3_uid181_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid448_pT3_uid181_invPolyEval_in(49 downto 12));

    -- redist11_osig_uid448_pT3_uid181_invPolyEval_b_1(DELAY,513)
    redist11_osig_uid448_pT3_uid181_invPolyEval_b_1 : dspba_delay
    GENERIC MAP ( width => 38, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid448_pT3_uid181_invPolyEval_b, xout => redist11_osig_uid448_pT3_uid181_invPolyEval_b_1_q, clk => clk, aclr => areset );

    -- redist44_yAddr_uid51_fpDivTest_b_13(DELAY,546)
    redist44_yAddr_uid51_fpDivTest_b_13 : dspba_delay
    GENERIC MAP ( width => 9, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist43_yAddr_uid51_fpDivTest_b_8_q, xout => redist44_yAddr_uid51_fpDivTest_b_13_q, clk => clk, aclr => areset );

    -- memoryC0_uid148_invTables_lutmem(DUALMEM,472)@13 + 2
    -- in j@20000000
    memoryC0_uid148_invTables_lutmem_aa <= redist44_yAddr_uid51_fpDivTest_b_13_q;
    memoryC0_uid148_invTables_lutmem_reset0 <= areset;
    memoryC0_uid148_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 8,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC0_uid148_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid148_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid148_invTables_lutmem_aa,
        q_a => memoryC0_uid148_invTables_lutmem_ir
    );
    memoryC0_uid148_invTables_lutmem_r <= memoryC0_uid148_invTables_lutmem_ir(7 downto 0);

    -- memoryC0_uid147_invTables_lutmem(DUALMEM,471)@13 + 2
    -- in j@20000000
    memoryC0_uid147_invTables_lutmem_aa <= redist44_yAddr_uid51_fpDivTest_b_13_q;
    memoryC0_uid147_invTables_lutmem_reset0 <= areset;
    memoryC0_uid147_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC0_uid147_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid147_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid147_invTables_lutmem_aa,
        q_a => memoryC0_uid147_invTables_lutmem_ir
    );
    memoryC0_uid147_invTables_lutmem_r <= memoryC0_uid147_invTables_lutmem_ir(17 downto 0);

    -- memoryC0_uid146_invTables_lutmem(DUALMEM,470)@13 + 2
    -- in j@20000000
    memoryC0_uid146_invTables_lutmem_aa <= redist44_yAddr_uid51_fpDivTest_b_13_q;
    memoryC0_uid146_invTables_lutmem_reset0 <= areset;
    memoryC0_uid146_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "DIV40_0002_memoryC0_uid146_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid146_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid146_invTables_lutmem_aa,
        q_a => memoryC0_uid146_invTables_lutmem_ir
    );
    memoryC0_uid146_invTables_lutmem_r <= memoryC0_uid146_invTables_lutmem_ir(17 downto 0);

    -- os_uid149_invTables(BITJOIN,148)@15
    os_uid149_invTables_q <= memoryC0_uid148_invTables_lutmem_r & memoryC0_uid147_invTables_lutmem_r & memoryC0_uid146_invTables_lutmem_r;

    -- rndBit_uid182_invPolyEval(CONSTANT,181)
    rndBit_uid182_invPolyEval_q <= "001";

    -- cIncludingRoundingBit_uid183_invPolyEval(BITJOIN,182)@15
    cIncludingRoundingBit_uid183_invPolyEval_q <= os_uid149_invTables_q & rndBit_uid182_invPolyEval_q;

    -- ts3_uid185_invPolyEval(ADD,184)@15
    ts3_uid185_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((47 downto 47 => cIncludingRoundingBit_uid183_invPolyEval_q(46)) & cIncludingRoundingBit_uid183_invPolyEval_q));
    ts3_uid185_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((47 downto 38 => redist11_osig_uid448_pT3_uid181_invPolyEval_b_1_q(37)) & redist11_osig_uid448_pT3_uid181_invPolyEval_b_1_q));
    ts3_uid185_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts3_uid185_invPolyEval_a) + SIGNED(ts3_uid185_invPolyEval_b));
    ts3_uid185_invPolyEval_q <= ts3_uid185_invPolyEval_o(47 downto 0);

    -- s3_uid186_invPolyEval(BITSELECT,185)@15
    s3_uid186_invPolyEval_b <= STD_LOGIC_VECTOR(ts3_uid185_invPolyEval_q(47 downto 1));

    -- invY_uid54_fpDivTest(BITSELECT,53)@15
    invY_uid54_fpDivTest_in <= s3_uid186_invPolyEval_b(43 downto 0);
    invY_uid54_fpDivTest_b <= invY_uid54_fpDivTest_in(43 downto 5);

    -- redist39_invY_uid54_fpDivTest_b_1(DELAY,541)
    redist39_invY_uid54_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 39, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => invY_uid54_fpDivTest_b, xout => redist39_invY_uid54_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest(BITSELECT,226)@16
    rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_in <= redist39_invY_uid54_fpDivTest_b_1_q(2 downto 0);
    rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_b <= rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_in(2 downto 0);

    -- rightBottomX_bottomExtension_uid226_divValPreNorm_uid59_fpDivTest(CONSTANT,225)
    rightBottomX_bottomExtension_uid226_divValPreNorm_uid59_fpDivTest_q <= "00";

    -- rightBottomX_mergedSignalTM_uid228_divValPreNorm_uid59_fpDivTest(BITJOIN,227)@16
    rightBottomX_mergedSignalTM_uid228_divValPreNorm_uid59_fpDivTest_q <= rightBottomX_bottomRange_uid227_divValPreNorm_uid59_fpDivTest_b & rightBottomX_bottomExtension_uid226_divValPreNorm_uid59_fpDivTest_q;

    -- n0_uid236_divValPreNorm_uid59_fpDivTest(BITSELECT,235)@16
    n0_uid236_divValPreNorm_uid59_fpDivTest_b <= rightBottomX_mergedSignalTM_uid228_divValPreNorm_uid59_fpDivTest_q(4 downto 1);

    -- n0_uid242_divValPreNorm_uid59_fpDivTest(BITSELECT,241)@16
    n0_uid242_divValPreNorm_uid59_fpDivTest_b <= n0_uid236_divValPreNorm_uid59_fpDivTest_b(3 downto 1);

    -- sm1_uid253_divValPreNorm_uid59_fpDivTest(MULT,252)@16 + 2
    sm1_uid253_divValPreNorm_uid59_fpDivTest_a0 <= n0_uid242_divValPreNorm_uid59_fpDivTest_b;
    sm1_uid253_divValPreNorm_uid59_fpDivTest_b0 <= n1_uid241_divValPreNorm_uid59_fpDivTest_b;
    sm1_uid253_divValPreNorm_uid59_fpDivTest_reset <= areset;
    sm1_uid253_divValPreNorm_uid59_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 3,
        lpm_widthb => 3,
        lpm_widthp => 6,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid253_divValPreNorm_uid59_fpDivTest_a0,
        datab => sm1_uid253_divValPreNorm_uid59_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm1_uid253_divValPreNorm_uid59_fpDivTest_reset,
        clock => clk,
        result => sm1_uid253_divValPreNorm_uid59_fpDivTest_s1
    );
    sm1_uid253_divValPreNorm_uid59_fpDivTest_q <= sm1_uid253_divValPreNorm_uid59_fpDivTest_s1;

    -- topRangeY_uid197_divValPreNorm_uid59_fpDivTest(BITSELECT,196)@16
    topRangeY_uid197_divValPreNorm_uid59_fpDivTest_b <= lOAdded_uid57_fpDivTest_q(31 downto 14);

    -- rightBottomX_uid219_divValPreNorm_uid59_fpDivTest(BITSELECT,218)@16
    rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_in <= redist39_invY_uid54_fpDivTest_b_1_q(20 downto 0);
    rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_b <= rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_in(20 downto 3);

    -- sm1_uid251_divValPreNorm_uid59_fpDivTest(MULT,250)@16 + 2
    sm1_uid251_divValPreNorm_uid59_fpDivTest_a0 <= rightBottomX_uid219_divValPreNorm_uid59_fpDivTest_b;
    sm1_uid251_divValPreNorm_uid59_fpDivTest_b0 <= topRangeY_uid197_divValPreNorm_uid59_fpDivTest_b;
    sm1_uid251_divValPreNorm_uid59_fpDivTest_reset <= areset;
    sm1_uid251_divValPreNorm_uid59_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid251_divValPreNorm_uid59_fpDivTest_a0,
        datab => sm1_uid251_divValPreNorm_uid59_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm1_uid251_divValPreNorm_uid59_fpDivTest_reset,
        clock => clk,
        result => sm1_uid251_divValPreNorm_uid59_fpDivTest_s1
    );
    sm1_uid251_divValPreNorm_uid59_fpDivTest_q <= sm1_uid251_divValPreNorm_uid59_fpDivTest_s1;

    -- lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select(BITSELECT,499)@18
    lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b <= sm1_uid251_divValPreNorm_uid59_fpDivTest_q(11 downto 0);
    lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_c <= sm1_uid251_divValPreNorm_uid59_fpDivTest_q(35 downto 12);

    -- lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest(ADD,260)@18 + 1
    lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_a <= STD_LOGIC_VECTOR("0" & lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_c);
    lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000" & sm1_uid253_divValPreNorm_uid59_fpDivTest_q);
    lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_a) + UNSIGNED(lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_b));
        END IF;
    END PROCESS;
    lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_q <= lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_o(24 downto 0);

    -- redist0_lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1(DELAY,502)
    redist0_lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 12, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b, xout => redist0_lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- lev1_a1_uid262_divValPreNorm_uid59_fpDivTest(BITJOIN,261)@19
    lev1_a1_uid262_divValPreNorm_uid59_fpDivTest_q <= lev1_a1high_uid261_divValPreNorm_uid59_fpDivTest_q & redist0_lowRangeA_uid259_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q;

    -- aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest(BITSELECT,215)@16
    aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_in <= lOAdded_uid57_fpDivTest_q(13 downto 0);
    aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_b <= aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_in(13 downto 0);

    -- aboveLeftY_mergedSignalTM_uid217_divValPreNorm_uid59_fpDivTest(BITJOIN,216)@16
    aboveLeftY_mergedSignalTM_uid217_divValPreNorm_uid59_fpDivTest_q <= aboveLeftY_bottomRange_uid216_divValPreNorm_uid59_fpDivTest_b & aboveLeftY_bottomExtension_uid215_divValPreNorm_uid59_fpDivTest_q;

    -- topRangeX_uid196_divValPreNorm_uid59_fpDivTest(BITSELECT,195)@16
    topRangeX_uid196_divValPreNorm_uid59_fpDivTest_b <= redist39_invY_uid54_fpDivTest_b_1_q(38 downto 21);

    -- sm0_uid250_divValPreNorm_uid59_fpDivTest(MULT,249)@16 + 2
    sm0_uid250_divValPreNorm_uid59_fpDivTest_a0 <= topRangeX_uid196_divValPreNorm_uid59_fpDivTest_b;
    sm0_uid250_divValPreNorm_uid59_fpDivTest_b0 <= aboveLeftY_mergedSignalTM_uid217_divValPreNorm_uid59_fpDivTest_q;
    sm0_uid250_divValPreNorm_uid59_fpDivTest_reset <= areset;
    sm0_uid250_divValPreNorm_uid59_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid250_divValPreNorm_uid59_fpDivTest_a0,
        datab => sm0_uid250_divValPreNorm_uid59_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid250_divValPreNorm_uid59_fpDivTest_reset,
        clock => clk,
        result => sm0_uid250_divValPreNorm_uid59_fpDivTest_s1
    );
    sm0_uid250_divValPreNorm_uid59_fpDivTest_q <= sm0_uid250_divValPreNorm_uid59_fpDivTest_s1;

    -- lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select(BITSELECT,498)@18
    lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b <= sm0_uid250_divValPreNorm_uid59_fpDivTest_q(11 downto 0);
    lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_c <= sm0_uid250_divValPreNorm_uid59_fpDivTest_q(35 downto 12);

    -- sm0_uid249_divValPreNorm_uid59_fpDivTest(MULT,248)@16 + 2
    sm0_uid249_divValPreNorm_uid59_fpDivTest_a0 <= topRangeX_uid196_divValPreNorm_uid59_fpDivTest_b;
    sm0_uid249_divValPreNorm_uid59_fpDivTest_b0 <= topRangeY_uid197_divValPreNorm_uid59_fpDivTest_b;
    sm0_uid249_divValPreNorm_uid59_fpDivTest_reset <= areset;
    sm0_uid249_divValPreNorm_uid59_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid249_divValPreNorm_uid59_fpDivTest_a0,
        datab => sm0_uid249_divValPreNorm_uid59_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid249_divValPreNorm_uid59_fpDivTest_reset,
        clock => clk,
        result => sm0_uid249_divValPreNorm_uid59_fpDivTest_s1
    );
    sm0_uid249_divValPreNorm_uid59_fpDivTest_q <= sm0_uid249_divValPreNorm_uid59_fpDivTest_s1;

    -- aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest(BITSELECT,224)@16
    aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_in <= lOAdded_uid57_fpDivTest_q(13 downto 0);
    aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_b <= aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_in(13 downto 9);

    -- n1_uid233_divValPreNorm_uid59_fpDivTest(BITSELECT,232)@16
    n1_uid233_divValPreNorm_uid59_fpDivTest_b <= aboveLeftY_uid225_divValPreNorm_uid59_fpDivTest_b(4 downto 1);

    -- n1_uid239_divValPreNorm_uid59_fpDivTest(BITSELECT,238)@16
    n1_uid239_divValPreNorm_uid59_fpDivTest_b <= n1_uid233_divValPreNorm_uid59_fpDivTest_b(3 downto 1);

    -- aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest(BITSELECT,223)@16
    aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_in <= redist39_invY_uid54_fpDivTest_b_1_q(20 downto 0);
    aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_b <= aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_in(20 downto 16);

    -- n0_uid234_divValPreNorm_uid59_fpDivTest(BITSELECT,233)@16
    n0_uid234_divValPreNorm_uid59_fpDivTest_b <= aboveLeftX_uid224_divValPreNorm_uid59_fpDivTest_b(4 downto 1);

    -- n0_uid240_divValPreNorm_uid59_fpDivTest(BITSELECT,239)@16
    n0_uid240_divValPreNorm_uid59_fpDivTest_b <= n0_uid234_divValPreNorm_uid59_fpDivTest_b(3 downto 1);

    -- sm0_uid252_divValPreNorm_uid59_fpDivTest(MULT,251)@16 + 2
    sm0_uid252_divValPreNorm_uid59_fpDivTest_a0 <= n0_uid240_divValPreNorm_uid59_fpDivTest_b;
    sm0_uid252_divValPreNorm_uid59_fpDivTest_b0 <= n1_uid239_divValPreNorm_uid59_fpDivTest_b;
    sm0_uid252_divValPreNorm_uid59_fpDivTest_reset <= areset;
    sm0_uid252_divValPreNorm_uid59_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 3,
        lpm_widthb => 3,
        lpm_widthp => 6,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid252_divValPreNorm_uid59_fpDivTest_a0,
        datab => sm0_uid252_divValPreNorm_uid59_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid252_divValPreNorm_uid59_fpDivTest_reset,
        clock => clk,
        result => sm0_uid252_divValPreNorm_uid59_fpDivTest_s1
    );
    sm0_uid252_divValPreNorm_uid59_fpDivTest_q <= sm0_uid252_divValPreNorm_uid59_fpDivTest_s1;

    -- sumAb_uid254_divValPreNorm_uid59_fpDivTest(BITJOIN,253)@18
    sumAb_uid254_divValPreNorm_uid59_fpDivTest_q <= sm0_uid249_divValPreNorm_uid59_fpDivTest_q & sm0_uid252_divValPreNorm_uid59_fpDivTest_q;

    -- lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest(ADD,256)@18 + 1
    lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_a <= STD_LOGIC_VECTOR("0" & sumAb_uid254_divValPreNorm_uid59_fpDivTest_q);
    lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000" & lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_c);
    lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_a) + UNSIGNED(lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_b));
        END IF;
    END PROCESS;
    lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_q <= lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_o(42 downto 0);

    -- redist1_lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1(DELAY,503)
    redist1_lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1 : dspba_delay
    GENERIC MAP ( width => 12, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b, xout => redist1_lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q, clk => clk, aclr => areset );

    -- lev1_a0_uid258_divValPreNorm_uid59_fpDivTest(BITJOIN,257)@19
    lev1_a0_uid258_divValPreNorm_uid59_fpDivTest_q <= lev1_a0sumAHighB_uid257_divValPreNorm_uid59_fpDivTest_q & redist1_lowRangeB_uid255_divValPreNorm_uid59_fpDivTest_merged_bit_select_b_1_q;

    -- lev2_a0_uid263_divValPreNorm_uid59_fpDivTest(ADD,262)@19
    lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_a <= STD_LOGIC_VECTOR("0" & lev1_a0_uid258_divValPreNorm_uid59_fpDivTest_q);
    lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000" & lev1_a1_uid262_divValPreNorm_uid59_fpDivTest_q);
    lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_a) + UNSIGNED(lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_b));
    lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_q <= lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_o(55 downto 0);

    -- osig_uid264_divValPreNorm_uid59_fpDivTest(BITSELECT,263)@19
    osig_uid264_divValPreNorm_uid59_fpDivTest_in <= lev2_a0_uid263_divValPreNorm_uid59_fpDivTest_q(53 downto 0);
    osig_uid264_divValPreNorm_uid59_fpDivTest_b <= osig_uid264_divValPreNorm_uid59_fpDivTest_in(53 downto 17);

    -- redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1(DELAY,524)
    redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 37, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid264_divValPreNorm_uid59_fpDivTest_b, xout => redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- updatedY_uid16_fpDivTest(BITJOIN,15)@19
    updatedY_uid16_fpDivTest_q <= GND_q & paddingY_uid15_fpDivTest_q;

    -- fracYZero_uid15_fpDivTest(LOGICAL,16)@19 + 1
    fracYZero_uid15_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist46_fracY_uid13_fpDivTest_b_19_outputreg_q);
    fracYZero_uid15_fpDivTest_qi <= "1" WHEN fracYZero_uid15_fpDivTest_a = updatedY_uid16_fpDivTest_q ELSE "0";
    fracYZero_uid15_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_qi, xout => fracYZero_uid15_fpDivTest_q, clk => clk, aclr => areset );

    -- divValPreNormYPow2Exc_uid63_fpDivTest(MUX,62)@20
    divValPreNormYPow2Exc_uid63_fpDivTest_s <= fracYZero_uid15_fpDivTest_q;
    divValPreNormYPow2Exc_uid63_fpDivTest_combproc: PROCESS (divValPreNormYPow2Exc_uid63_fpDivTest_s, redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1_q, oFracXZ4_uid61_fpDivTest_q)
    BEGIN
        CASE (divValPreNormYPow2Exc_uid63_fpDivTest_s) IS
            WHEN "0" => divValPreNormYPow2Exc_uid63_fpDivTest_q <= redist22_osig_uid264_divValPreNorm_uid59_fpDivTest_b_1_q;
            WHEN "1" => divValPreNormYPow2Exc_uid63_fpDivTest_q <= oFracXZ4_uid61_fpDivTest_q;
            WHEN OTHERS => divValPreNormYPow2Exc_uid63_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- norm_uid64_fpDivTest(BITSELECT,63)@20
    norm_uid64_fpDivTest_b <= STD_LOGIC_VECTOR(divValPreNormYPow2Exc_uid63_fpDivTest_q(36 downto 36));

    -- redist35_norm_uid64_fpDivTest_b_1(DELAY,537)
    redist35_norm_uid64_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => norm_uid64_fpDivTest_b, xout => redist35_norm_uid64_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- zeroPaddingInAddition_uid74_fpDivTest(CONSTANT,73)
    zeroPaddingInAddition_uid74_fpDivTest_q <= "00000000000000000000000000000000";

    -- expFracPostRnd_uid75_fpDivTest(BITJOIN,74)@21
    expFracPostRnd_uid75_fpDivTest_q <= redist35_norm_uid64_fpDivTest_b_1_q & zeroPaddingInAddition_uid74_fpDivTest_q & VCC_q;

    -- cstBiasM1_uid6_fpDivTest(CONSTANT,5)
    cstBiasM1_uid6_fpDivTest_q <= "01111110";

    -- expXmY_uid47_fpDivTest(SUB,46)@20
    expXmY_uid47_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist56_expX_uid9_fpDivTest_b_20_outputreg_q);
    expXmY_uid47_fpDivTest_b <= STD_LOGIC_VECTOR("0" & redist49_expY_uid12_fpDivTest_b_20_mem_q);
    expXmY_uid47_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expXmY_uid47_fpDivTest_a) - UNSIGNED(expXmY_uid47_fpDivTest_b));
    expXmY_uid47_fpDivTest_q <= expXmY_uid47_fpDivTest_o(8 downto 0);

    -- expR_uid48_fpDivTest(ADD,47)@20 + 1
    expR_uid48_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 9 => expXmY_uid47_fpDivTest_q(8)) & expXmY_uid47_fpDivTest_q));
    expR_uid48_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & cstBiasM1_uid6_fpDivTest_q));
    expR_uid48_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expR_uid48_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expR_uid48_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expR_uid48_fpDivTest_a) + SIGNED(expR_uid48_fpDivTest_b));
        END IF;
    END PROCESS;
    expR_uid48_fpDivTest_q <= expR_uid48_fpDivTest_o(9 downto 0);

    -- divValPreNormHigh_uid65_fpDivTest(BITSELECT,64)@20
    divValPreNormHigh_uid65_fpDivTest_in <= divValPreNormYPow2Exc_uid63_fpDivTest_q(35 downto 0);
    divValPreNormHigh_uid65_fpDivTest_b <= divValPreNormHigh_uid65_fpDivTest_in(35 downto 3);

    -- divValPreNormLow_uid66_fpDivTest(BITSELECT,65)@20
    divValPreNormLow_uid66_fpDivTest_in <= divValPreNormYPow2Exc_uid63_fpDivTest_q(34 downto 0);
    divValPreNormLow_uid66_fpDivTest_b <= divValPreNormLow_uid66_fpDivTest_in(34 downto 2);

    -- normFracRnd_uid67_fpDivTest(MUX,66)@20 + 1
    normFracRnd_uid67_fpDivTest_s <= norm_uid64_fpDivTest_b;
    normFracRnd_uid67_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            normFracRnd_uid67_fpDivTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (normFracRnd_uid67_fpDivTest_s) IS
                WHEN "0" => normFracRnd_uid67_fpDivTest_q <= divValPreNormLow_uid66_fpDivTest_b;
                WHEN "1" => normFracRnd_uid67_fpDivTest_q <= divValPreNormHigh_uid65_fpDivTest_b;
                WHEN OTHERS => normFracRnd_uid67_fpDivTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- expFracRnd_uid68_fpDivTest(BITJOIN,67)@21
    expFracRnd_uid68_fpDivTest_q <= expR_uid48_fpDivTest_q & normFracRnd_uid67_fpDivTest_q;

    -- expFracPostRnd_uid76_fpDivTest(ADD,75)@21 + 1
    expFracPostRnd_uid76_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((44 downto 43 => expFracRnd_uid68_fpDivTest_q(42)) & expFracRnd_uid68_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000000000" & expFracPostRnd_uid75_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expFracPostRnd_uid76_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expFracPostRnd_uid76_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expFracPostRnd_uid76_fpDivTest_a) + SIGNED(expFracPostRnd_uid76_fpDivTest_b));
        END IF;
    END PROCESS;
    expFracPostRnd_uid76_fpDivTest_q <= expFracPostRnd_uid76_fpDivTest_o(43 downto 0);

    -- fracPostRndF_uid79_fpDivTest(BITSELECT,78)@22
    fracPostRndF_uid79_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(32 downto 0);
    fracPostRndF_uid79_fpDivTest_b <= fracPostRndF_uid79_fpDivTest_in(32 downto 1);

    -- invYO_uid55_fpDivTest(BITSELECT,54)@15
    invYO_uid55_fpDivTest_in <= STD_LOGIC_VECTOR(s3_uid186_invPolyEval_b(44 downto 0));
    invYO_uid55_fpDivTest_b <= STD_LOGIC_VECTOR(invYO_uid55_fpDivTest_in(44 downto 44));

    -- redist37_invYO_uid55_fpDivTest_b_7(DELAY,539)
    redist37_invYO_uid55_fpDivTest_b_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => invYO_uid55_fpDivTest_b, xout => redist37_invYO_uid55_fpDivTest_b_7_q, clk => clk, aclr => areset );

    -- fracPostRndF_uid80_fpDivTest(MUX,79)@22
    fracPostRndF_uid80_fpDivTest_s <= redist37_invYO_uid55_fpDivTest_b_7_q;
    fracPostRndF_uid80_fpDivTest_combproc: PROCESS (fracPostRndF_uid80_fpDivTest_s, fracPostRndF_uid79_fpDivTest_b, fracXExt_uid77_fpDivTest_q)
    BEGIN
        CASE (fracPostRndF_uid80_fpDivTest_s) IS
            WHEN "0" => fracPostRndF_uid80_fpDivTest_q <= fracPostRndF_uid79_fpDivTest_b;
            WHEN "1" => fracPostRndF_uid80_fpDivTest_q <= fracXExt_uid77_fpDivTest_q;
            WHEN OTHERS => fracPostRndF_uid80_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr(REG,564)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr_q <= "101";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr_q <= STD_LOGIC_VECTOR(redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist34_fracPostRndF_uid80_fpDivTest_q_7_mem(DUALMEM,562)
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ia <= STD_LOGIC_VECTOR(fracPostRndF_uid80_fpDivTest_q);
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_aa <= redist34_fracPostRndF_uid80_fpDivTest_q_7_wraddr_q;
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ab <= redist34_fracPostRndF_uid80_fpDivTest_q_7_rdcnt_q;
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_reset0 <= areset;
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 32,
        widthad_a => 3,
        numwords_a => 6,
        width_b => 32,
        widthad_b => 3,
        numwords_b => 6,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist34_fracPostRndF_uid80_fpDivTest_q_7_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_reset0,
        clock1 => clk,
        address_a => redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_aa,
        data_a => redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_ab,
        q_b => redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_iq
    );
    redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_q <= redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_iq(31 downto 0);

    -- betweenFPwF_uid102_fpDivTest(BITSELECT,101)@29
    betweenFPwF_uid102_fpDivTest_in <= STD_LOGIC_VECTOR(redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_q(0 downto 0));
    betweenFPwF_uid102_fpDivTest_b <= STD_LOGIC_VECTOR(betweenFPwF_uid102_fpDivTest_in(0 downto 0));

    -- redist58_expX_uid9_fpDivTest_b_27(DELAY,560)
    redist58_expX_uid9_fpDivTest_b_27 : dspba_delay
    GENERIC MAP ( width => 8, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist57_expX_uid9_fpDivTest_b_22_q, xout => redist58_expX_uid9_fpDivTest_b_27_q, clk => clk, aclr => areset );

    -- redist59_expX_uid9_fpDivTest_b_29(DELAY,561)
    redist59_expX_uid9_fpDivTest_b_29 : dspba_delay
    GENERIC MAP ( width => 8, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist58_expX_uid9_fpDivTest_b_27_q, xout => redist59_expX_uid9_fpDivTest_b_29_q, clk => clk, aclr => areset );

    -- redist55_fracX_uid10_fpDivTest_b_29_notEnable(LOGICAL,613)
    redist55_fracX_uid10_fpDivTest_b_29_notEnable_q <= STD_LOGIC_VECTOR(not (VCC_q));

    -- redist55_fracX_uid10_fpDivTest_b_29_nor(LOGICAL,614)
    redist55_fracX_uid10_fpDivTest_b_29_nor_q <= not (redist55_fracX_uid10_fpDivTest_b_29_notEnable_q or redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_q);

    -- redist55_fracX_uid10_fpDivTest_b_29_mem_last(CONSTANT,610)
    redist55_fracX_uid10_fpDivTest_b_29_mem_last_q <= "010";

    -- redist55_fracX_uid10_fpDivTest_b_29_cmp(LOGICAL,611)
    redist55_fracX_uid10_fpDivTest_b_29_cmp_b <= STD_LOGIC_VECTOR("0" & redist55_fracX_uid10_fpDivTest_b_29_rdcnt_q);
    redist55_fracX_uid10_fpDivTest_b_29_cmp_q <= "1" WHEN redist55_fracX_uid10_fpDivTest_b_29_mem_last_q = redist55_fracX_uid10_fpDivTest_b_29_cmp_b ELSE "0";

    -- redist55_fracX_uid10_fpDivTest_b_29_cmpReg(REG,612)
    redist55_fracX_uid10_fpDivTest_b_29_cmpReg_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_cmpReg_q <= STD_LOGIC_VECTOR(redist55_fracX_uid10_fpDivTest_b_29_cmp_q);
        END IF;
    END PROCESS;

    -- redist55_fracX_uid10_fpDivTest_b_29_sticky_ena(REG,615)
    redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist55_fracX_uid10_fpDivTest_b_29_nor_q = "1") THEN
                redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_q <= STD_LOGIC_VECTOR(redist55_fracX_uid10_fpDivTest_b_29_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist55_fracX_uid10_fpDivTest_b_29_enaAnd(LOGICAL,616)
    redist55_fracX_uid10_fpDivTest_b_29_enaAnd_q <= redist55_fracX_uid10_fpDivTest_b_29_sticky_ena_q and VCC_q;

    -- redist55_fracX_uid10_fpDivTest_b_29_rdcnt(COUNTER,608)
    -- low=0, high=3, step=1, init=0
    redist55_fracX_uid10_fpDivTest_b_29_rdcnt_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i <= TO_UNSIGNED(0, 2);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i <= redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist55_fracX_uid10_fpDivTest_b_29_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist55_fracX_uid10_fpDivTest_b_29_rdcnt_i, 2)));

    -- redist55_fracX_uid10_fpDivTest_b_29_inputreg(DELAY,605)
    redist55_fracX_uid10_fpDivTest_b_29_inputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist54_fracX_uid10_fpDivTest_b_22_q, xout => redist55_fracX_uid10_fpDivTest_b_29_inputreg_q, clk => clk, aclr => areset );

    -- redist55_fracX_uid10_fpDivTest_b_29_wraddr(REG,609)
    redist55_fracX_uid10_fpDivTest_b_29_wraddr_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_wraddr_q <= "11";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist55_fracX_uid10_fpDivTest_b_29_wraddr_q <= STD_LOGIC_VECTOR(redist55_fracX_uid10_fpDivTest_b_29_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist55_fracX_uid10_fpDivTest_b_29_mem(DUALMEM,607)
    redist55_fracX_uid10_fpDivTest_b_29_mem_ia <= STD_LOGIC_VECTOR(redist55_fracX_uid10_fpDivTest_b_29_inputreg_q);
    redist55_fracX_uid10_fpDivTest_b_29_mem_aa <= redist55_fracX_uid10_fpDivTest_b_29_wraddr_q;
    redist55_fracX_uid10_fpDivTest_b_29_mem_ab <= redist55_fracX_uid10_fpDivTest_b_29_rdcnt_q;
    redist55_fracX_uid10_fpDivTest_b_29_mem_reset0 <= areset;
    redist55_fracX_uid10_fpDivTest_b_29_mem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "DUAL_PORT",
        width_a => 31,
        widthad_a => 2,
        numwords_a => 4,
        width_b => 31,
        widthad_b => 2,
        numwords_b => 4,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        wrcontrol_wraddress_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken1 => redist55_fracX_uid10_fpDivTest_b_29_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist55_fracX_uid10_fpDivTest_b_29_mem_reset0,
        clock1 => clk,
        address_a => redist55_fracX_uid10_fpDivTest_b_29_mem_aa,
        data_a => redist55_fracX_uid10_fpDivTest_b_29_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist55_fracX_uid10_fpDivTest_b_29_mem_ab,
        q_b => redist55_fracX_uid10_fpDivTest_b_29_mem_iq
    );
    redist55_fracX_uid10_fpDivTest_b_29_mem_q <= redist55_fracX_uid10_fpDivTest_b_29_mem_iq(30 downto 0);

    -- redist55_fracX_uid10_fpDivTest_b_29_outputreg(DELAY,606)
    redist55_fracX_uid10_fpDivTest_b_29_outputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist55_fracX_uid10_fpDivTest_b_29_mem_q, xout => redist55_fracX_uid10_fpDivTest_b_29_outputreg_q, clk => clk, aclr => areset );

    -- qDivProdLTX_opB_uid100_fpDivTest(BITJOIN,99)@29
    qDivProdLTX_opB_uid100_fpDivTest_q <= redist59_expX_uid9_fpDivTest_b_29_q & redist55_fracX_uid10_fpDivTest_b_29_outputreg_q;

    -- redist48_fracY_uid13_fpDivTest_b_22(DELAY,550)
    redist48_fracY_uid13_fpDivTest_b_22 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist47_fracY_uid13_fpDivTest_b_21_q, xout => redist48_fracY_uid13_fpDivTest_b_22_q, clk => clk, aclr => areset );

    -- lOAdded_uid87_fpDivTest(BITJOIN,86)@22
    lOAdded_uid87_fpDivTest_q <= VCC_q & redist48_fracY_uid13_fpDivTest_b_22_q;

    -- qDivProd_uid89_fpDivTest_bs10(BITSELECT,459)@22
    qDivProd_uid89_fpDivTest_bs10_b <= lOAdded_uid87_fpDivTest_q(31 downto 18);

    -- redist6_qDivProd_uid89_fpDivTest_bs10_b_1(DELAY,508)
    redist6_qDivProd_uid89_fpDivTest_bs10_b_1 : dspba_delay
    GENERIC MAP ( width => 14, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_bs10_b, xout => redist6_qDivProd_uid89_fpDivTest_bs10_b_1_q, clk => clk, aclr => areset );

    -- lOAdded_uid84_fpDivTest(BITJOIN,83)@22
    lOAdded_uid84_fpDivTest_q <= VCC_q & fracPostRndF_uid80_fpDivTest_q;

    -- qDivProd_uid89_fpDivTest_bs9(BITSELECT,458)@22
    qDivProd_uid89_fpDivTest_bs9_in <= lOAdded_uid84_fpDivTest_q(17 downto 0);
    qDivProd_uid89_fpDivTest_bs9_b <= qDivProd_uid89_fpDivTest_bs9_in(17 downto 0);

    -- redist7_qDivProd_uid89_fpDivTest_bs9_b_1(DELAY,509)
    redist7_qDivProd_uid89_fpDivTest_bs9_b_1 : dspba_delay
    GENERIC MAP ( width => 18, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_bs9_b, xout => redist7_qDivProd_uid89_fpDivTest_bs9_b_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_im8(MULT,457)@23 + 2
    qDivProd_uid89_fpDivTest_im8_a0 <= redist7_qDivProd_uid89_fpDivTest_bs9_b_1_q;
    qDivProd_uid89_fpDivTest_im8_b0 <= redist6_qDivProd_uid89_fpDivTest_bs10_b_1_q;
    qDivProd_uid89_fpDivTest_im8_reset <= areset;
    qDivProd_uid89_fpDivTest_im8_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 14,
        lpm_widthp => 32,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => qDivProd_uid89_fpDivTest_im8_a0,
        datab => qDivProd_uid89_fpDivTest_im8_b0,
        clken => VCC_q(0),
        aclr => qDivProd_uid89_fpDivTest_im8_reset,
        clock => clk,
        result => qDivProd_uid89_fpDivTest_im8_s1
    );
    qDivProd_uid89_fpDivTest_im8_q <= qDivProd_uid89_fpDivTest_im8_s1;

    -- redist8_qDivProd_uid89_fpDivTest_im8_q_1(DELAY,510)
    redist8_qDivProd_uid89_fpDivTest_im8_q_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_im8_q, xout => redist8_qDivProd_uid89_fpDivTest_im8_q_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_align_17(BITSHIFT,466)@26
    qDivProd_uid89_fpDivTest_align_17_qint <= redist8_qDivProd_uid89_fpDivTest_im8_q_1_q & "000000000000000000";
    qDivProd_uid89_fpDivTest_align_17_q <= qDivProd_uid89_fpDivTest_align_17_qint(49 downto 0);

    -- qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_BitJoin_for_b(BITJOIN,494)@26
    qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_BitJoin_for_b_q <= qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_b & qDivProd_uid89_fpDivTest_align_17_q;

    -- qDivProd_uid89_fpDivTest_bs6(BITSELECT,455)@22
    qDivProd_uid89_fpDivTest_bs6_b <= lOAdded_uid84_fpDivTest_q(32 downto 18);

    -- qDivProd_uid89_fpDivTest_bs7(BITSELECT,456)@22
    qDivProd_uid89_fpDivTest_bs7_in <= lOAdded_uid87_fpDivTest_q(17 downto 0);
    qDivProd_uid89_fpDivTest_bs7_b <= qDivProd_uid89_fpDivTest_bs7_in(17 downto 0);

    -- qDivProd_uid89_fpDivTest_im5(MULT,454)@22 + 2
    qDivProd_uid89_fpDivTest_im5_a0 <= qDivProd_uid89_fpDivTest_bs7_b;
    qDivProd_uid89_fpDivTest_im5_b0 <= qDivProd_uid89_fpDivTest_bs6_b;
    qDivProd_uid89_fpDivTest_im5_reset <= areset;
    qDivProd_uid89_fpDivTest_im5_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 15,
        lpm_widthp => 33,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => qDivProd_uid89_fpDivTest_im5_a0,
        datab => qDivProd_uid89_fpDivTest_im5_b0,
        clken => VCC_q(0),
        aclr => qDivProd_uid89_fpDivTest_im5_reset,
        clock => clk,
        result => qDivProd_uid89_fpDivTest_im5_s1
    );
    qDivProd_uid89_fpDivTest_im5_q <= qDivProd_uid89_fpDivTest_im5_s1;

    -- redist9_qDivProd_uid89_fpDivTest_im5_q_1(DELAY,511)
    redist9_qDivProd_uid89_fpDivTest_im5_q_1 : dspba_delay
    GENERIC MAP ( width => 33, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_im5_q, xout => redist9_qDivProd_uid89_fpDivTest_im5_q_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_align_15(BITSHIFT,464)@25
    qDivProd_uid89_fpDivTest_align_15_qint <= redist9_qDivProd_uid89_fpDivTest_im5_q_1_q & "000000000000000000";
    qDivProd_uid89_fpDivTest_align_15_q <= qDivProd_uid89_fpDivTest_align_15_qint(50 downto 0);

    -- qDivProd_uid89_fpDivTest_bs3(BITSELECT,452)@22
    qDivProd_uid89_fpDivTest_bs3_b <= STD_LOGIC_VECTOR(lOAdded_uid87_fpDivTest_q(31 downto 18));

    -- qDivProd_uid89_fpDivTest_bjB4(BITJOIN,453)@22
    qDivProd_uid89_fpDivTest_bjB4_q <= GND_q & qDivProd_uid89_fpDivTest_bs3_b;

    -- qDivProd_uid89_fpDivTest_bs1(BITSELECT,450)@22
    qDivProd_uid89_fpDivTest_bs1_b <= STD_LOGIC_VECTOR(lOAdded_uid84_fpDivTest_q(32 downto 18));

    -- qDivProd_uid89_fpDivTest_bjA2(BITJOIN,451)@22
    qDivProd_uid89_fpDivTest_bjA2_q <= GND_q & qDivProd_uid89_fpDivTest_bs1_b;

    -- qDivProd_uid89_fpDivTest_im0(MULT,449)@22 + 2
    qDivProd_uid89_fpDivTest_im0_a0 <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_bjA2_q);
    qDivProd_uid89_fpDivTest_im0_b0 <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_bjB4_q);
    qDivProd_uid89_fpDivTest_im0_reset <= areset;
    qDivProd_uid89_fpDivTest_im0_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 16,
        lpm_widthb => 15,
        lpm_widthp => 31,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => qDivProd_uid89_fpDivTest_im0_a0,
        datab => qDivProd_uid89_fpDivTest_im0_b0,
        clken => VCC_q(0),
        aclr => qDivProd_uid89_fpDivTest_im0_reset,
        clock => clk,
        result => qDivProd_uid89_fpDivTest_im0_s1
    );
    qDivProd_uid89_fpDivTest_im0_q <= qDivProd_uid89_fpDivTest_im0_s1;

    -- redist10_qDivProd_uid89_fpDivTest_im0_q_1(DELAY,512)
    redist10_qDivProd_uid89_fpDivTest_im0_q_1 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_im0_q, xout => redist10_qDivProd_uid89_fpDivTest_im0_q_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_im11(MULT,460)@22 + 2
    qDivProd_uid89_fpDivTest_im11_a0 <= qDivProd_uid89_fpDivTest_bs9_b;
    qDivProd_uid89_fpDivTest_im11_b0 <= qDivProd_uid89_fpDivTest_bs7_b;
    qDivProd_uid89_fpDivTest_im11_reset <= areset;
    qDivProd_uid89_fpDivTest_im11_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => qDivProd_uid89_fpDivTest_im11_a0,
        datab => qDivProd_uid89_fpDivTest_im11_b0,
        clken => VCC_q(0),
        aclr => qDivProd_uid89_fpDivTest_im11_reset,
        clock => clk,
        result => qDivProd_uid89_fpDivTest_im11_s1
    );
    qDivProd_uid89_fpDivTest_im11_q <= qDivProd_uid89_fpDivTest_im11_s1;

    -- redist5_qDivProd_uid89_fpDivTest_im11_q_1(DELAY,507)
    redist5_qDivProd_uid89_fpDivTest_im11_q_1 : dspba_delay
    GENERIC MAP ( width => 36, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_im11_q, xout => redist5_qDivProd_uid89_fpDivTest_im11_q_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_join_14(BITJOIN,463)@25
    qDivProd_uid89_fpDivTest_join_14_q <= redist10_qDivProd_uid89_fpDivTest_im0_q_1_q & redist5_qDivProd_uid89_fpDivTest_im11_q_1_q;

    -- qDivProd_uid89_fpDivTest_result_add_0_0(ADD,468)@25 + 1
    qDivProd_uid89_fpDivTest_result_add_0_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((68 downto 67 => qDivProd_uid89_fpDivTest_join_14_q(66)) & qDivProd_uid89_fpDivTest_join_14_q));
    qDivProd_uid89_fpDivTest_result_add_0_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000000000000000" & qDivProd_uid89_fpDivTest_align_15_q));
    qDivProd_uid89_fpDivTest_result_add_0_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_0_0_o <= STD_LOGIC_VECTOR(SIGNED(qDivProd_uid89_fpDivTest_result_add_0_0_a) + SIGNED(qDivProd_uid89_fpDivTest_result_add_0_0_b));
        END IF;
    END PROCESS;
    qDivProd_uid89_fpDivTest_result_add_0_0_q <= qDivProd_uid89_fpDivTest_result_add_0_0_o(67 downto 0);

    -- qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2(ADD,485)@26 + 1
    qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_a <= STD_LOGIC_VECTOR("0" & qDivProd_uid89_fpDivTest_result_add_0_0_q);
    qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_b <= STD_LOGIC_VECTOR("0" & qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_BitJoin_for_b_q);
    qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_o <= STD_LOGIC_VECTOR(UNSIGNED(qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_a) + UNSIGNED(qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_b));
        END IF;
    END PROCESS;
    qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_c(0) <= qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_o(68);
    qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q <= qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_o(67 downto 0);

    -- qDivProd_uid89_fpDivTest_result_add_1_0_UpperBits_for_b(CONSTANT,482)
    qDivProd_uid89_fpDivTest_result_add_1_0_UpperBits_for_b_q <= "0000000000000000000";

    -- qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select(BITSELECT,501)
    qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_b <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_result_add_1_0_UpperBits_for_b_q(17 downto 0));
    qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_c <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_result_add_1_0_UpperBits_for_b_q(18 downto 18));

    -- qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0(BITSELECT,490)@26
    qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_result_add_0_0_q(67 downto 67));

    -- redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1(DELAY,505)
    redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b, xout => redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2(ADD,486)@27 + 1
    qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_cin <= qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_c;
    qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((1 downto 1 => redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1_q(0)) & redist3_qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_a_tessel1_0_b_1_q) & '1');
    qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & qDivProd_uid89_fpDivTest_result_add_1_0_BitSelect_for_b_tessel0_1_merged_bit_select_c) & qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_cin(0));
    qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_o <= STD_LOGIC_VECTOR(SIGNED(qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_a) + SIGNED(qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_b));
        END IF;
    END PROCESS;
    qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_q <= qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_o(1 downto 1);

    -- redist4_qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q_1(DELAY,506)
    redist4_qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q_1 : dspba_delay
    GENERIC MAP ( width => 68, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q, xout => redist4_qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q_1_q, clk => clk, aclr => areset );

    -- qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q(BITJOIN,487)@28
    qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q_q <= qDivProd_uid89_fpDivTest_result_add_1_0_p2_of_2_q & redist4_qDivProd_uid89_fpDivTest_result_add_1_0_p1_of_2_q_1_q;

    -- qDivProdNorm_uid90_fpDivTest(BITSELECT,89)@28
    qDivProdNorm_uid90_fpDivTest_in <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q_q(64 downto 0));
    qDivProdNorm_uid90_fpDivTest_b <= STD_LOGIC_VECTOR(qDivProdNorm_uid90_fpDivTest_in(64 downto 64));

    -- cstBias_uid7_fpDivTest(CONSTANT,6)
    cstBias_uid7_fpDivTest_q <= "01111111";

    -- qDivProdExp_opBs_uid95_fpDivTest(SUB,94)@28
    qDivProdExp_opBs_uid95_fpDivTest_a <= STD_LOGIC_VECTOR("0" & cstBias_uid7_fpDivTest_q);
    qDivProdExp_opBs_uid95_fpDivTest_b <= STD_LOGIC_VECTOR("00000000" & qDivProdNorm_uid90_fpDivTest_b);
    qDivProdExp_opBs_uid95_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDivProdExp_opBs_uid95_fpDivTest_a) - UNSIGNED(qDivProdExp_opBs_uid95_fpDivTest_b));
    qDivProdExp_opBs_uid95_fpDivTest_q <= qDivProdExp_opBs_uid95_fpDivTest_o(8 downto 0);

    -- expPostRndFR_uid81_fpDivTest(BITSELECT,80)@22
    expPostRndFR_uid81_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(40 downto 0);
    expPostRndFR_uid81_fpDivTest_b <= expPostRndFR_uid81_fpDivTest_in(40 downto 33);

    -- redist32_expPostRndFR_uid81_fpDivTest_b_5(DELAY,534)
    redist32_expPostRndFR_uid81_fpDivTest_b_5 : dspba_delay
    GENERIC MAP ( width => 8, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => expPostRndFR_uid81_fpDivTest_b, xout => redist32_expPostRndFR_uid81_fpDivTest_b_5_q, clk => clk, aclr => areset );

    -- redist38_invYO_uid55_fpDivTest_b_12(DELAY,540)
    redist38_invYO_uid55_fpDivTest_b_12 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist37_invYO_uid55_fpDivTest_b_7_q, xout => redist38_invYO_uid55_fpDivTest_b_12_q, clk => clk, aclr => areset );

    -- expPostRndF_uid82_fpDivTest(MUX,81)@27
    expPostRndF_uid82_fpDivTest_s <= redist38_invYO_uid55_fpDivTest_b_12_q;
    expPostRndF_uid82_fpDivTest_combproc: PROCESS (expPostRndF_uid82_fpDivTest_s, redist32_expPostRndFR_uid81_fpDivTest_b_5_q, redist58_expX_uid9_fpDivTest_b_27_q)
    BEGIN
        CASE (expPostRndF_uid82_fpDivTest_s) IS
            WHEN "0" => expPostRndF_uid82_fpDivTest_q <= redist32_expPostRndFR_uid81_fpDivTest_b_5_q;
            WHEN "1" => expPostRndF_uid82_fpDivTest_q <= redist58_expX_uid9_fpDivTest_b_27_q;
            WHEN OTHERS => expPostRndF_uid82_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- redist51_expY_uid12_fpDivTest_b_27(DELAY,553)
    redist51_expY_uid12_fpDivTest_b_27 : dspba_delay
    GENERIC MAP ( width => 8, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist50_expY_uid12_fpDivTest_b_22_q, xout => redist51_expY_uid12_fpDivTest_b_27_q, clk => clk, aclr => areset );

    -- qDivProdExp_opA_uid94_fpDivTest(ADD,93)@27 + 1
    qDivProdExp_opA_uid94_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist51_expY_uid12_fpDivTest_b_27_q);
    qDivProdExp_opA_uid94_fpDivTest_b <= STD_LOGIC_VECTOR("0" & expPostRndF_uid82_fpDivTest_q);
    qDivProdExp_opA_uid94_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProdExp_opA_uid94_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProdExp_opA_uid94_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDivProdExp_opA_uid94_fpDivTest_a) + UNSIGNED(qDivProdExp_opA_uid94_fpDivTest_b));
        END IF;
    END PROCESS;
    qDivProdExp_opA_uid94_fpDivTest_q <= qDivProdExp_opA_uid94_fpDivTest_o(8 downto 0);

    -- qDivProdExp_uid96_fpDivTest(SUB,95)@28
    qDivProdExp_uid96_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & qDivProdExp_opA_uid94_fpDivTest_q));
    qDivProdExp_uid96_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 9 => qDivProdExp_opBs_uid95_fpDivTest_q(8)) & qDivProdExp_opBs_uid95_fpDivTest_q));
    qDivProdExp_uid96_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(qDivProdExp_uid96_fpDivTest_a) - SIGNED(qDivProdExp_uid96_fpDivTest_b));
    qDivProdExp_uid96_fpDivTest_q <= qDivProdExp_uid96_fpDivTest_o(10 downto 0);

    -- qDivProdLTX_opA_uid98_fpDivTest(BITSELECT,97)@28
    qDivProdLTX_opA_uid98_fpDivTest_in <= qDivProdExp_uid96_fpDivTest_q(7 downto 0);
    qDivProdLTX_opA_uid98_fpDivTest_b <= qDivProdLTX_opA_uid98_fpDivTest_in(7 downto 0);

    -- redist30_qDivProdLTX_opA_uid98_fpDivTest_b_1(DELAY,532)
    redist30_qDivProdLTX_opA_uid98_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdLTX_opA_uid98_fpDivTest_b, xout => redist30_qDivProdLTX_opA_uid98_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- qDivProdFracHigh_uid91_fpDivTest(BITSELECT,90)@28
    qDivProdFracHigh_uid91_fpDivTest_in <= qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q_q(63 downto 0);
    qDivProdFracHigh_uid91_fpDivTest_b <= qDivProdFracHigh_uid91_fpDivTest_in(63 downto 32);

    -- qDivProdFracLow_uid92_fpDivTest(BITSELECT,91)@28
    qDivProdFracLow_uid92_fpDivTest_in <= qDivProd_uid89_fpDivTest_result_add_1_0_BitJoin_for_q_q(62 downto 0);
    qDivProdFracLow_uid92_fpDivTest_b <= qDivProdFracLow_uid92_fpDivTest_in(62 downto 31);

    -- qDivProdFrac_uid93_fpDivTest(MUX,92)@28
    qDivProdFrac_uid93_fpDivTest_s <= qDivProdNorm_uid90_fpDivTest_b;
    qDivProdFrac_uid93_fpDivTest_combproc: PROCESS (qDivProdFrac_uid93_fpDivTest_s, qDivProdFracLow_uid92_fpDivTest_b, qDivProdFracHigh_uid91_fpDivTest_b)
    BEGIN
        CASE (qDivProdFrac_uid93_fpDivTest_s) IS
            WHEN "0" => qDivProdFrac_uid93_fpDivTest_q <= qDivProdFracLow_uid92_fpDivTest_b;
            WHEN "1" => qDivProdFrac_uid93_fpDivTest_q <= qDivProdFracHigh_uid91_fpDivTest_b;
            WHEN OTHERS => qDivProdFrac_uid93_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- qDivProdFracWF_uid97_fpDivTest(BITSELECT,96)@28
    qDivProdFracWF_uid97_fpDivTest_b <= qDivProdFrac_uid93_fpDivTest_q(31 downto 1);

    -- redist31_qDivProdFracWF_uid97_fpDivTest_b_1(DELAY,533)
    redist31_qDivProdFracWF_uid97_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdFracWF_uid97_fpDivTest_b, xout => redist31_qDivProdFracWF_uid97_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- qDivProdLTX_opA_uid99_fpDivTest(BITJOIN,98)@29
    qDivProdLTX_opA_uid99_fpDivTest_q <= redist30_qDivProdLTX_opA_uid98_fpDivTest_b_1_q & redist31_qDivProdFracWF_uid97_fpDivTest_b_1_q;

    -- qDividerProdLTX_uid101_fpDivTest(COMPARE,100)@29
    qDividerProdLTX_uid101_fpDivTest_a <= STD_LOGIC_VECTOR("00" & qDivProdLTX_opA_uid99_fpDivTest_q);
    qDividerProdLTX_uid101_fpDivTest_b <= STD_LOGIC_VECTOR("00" & qDivProdLTX_opB_uid100_fpDivTest_q);
    qDividerProdLTX_uid101_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDividerProdLTX_uid101_fpDivTest_a) - UNSIGNED(qDividerProdLTX_uid101_fpDivTest_b));
    qDividerProdLTX_uid101_fpDivTest_c(0) <= qDividerProdLTX_uid101_fpDivTest_o(40);

    -- extraUlp_uid103_fpDivTest(LOGICAL,102)@29 + 1
    extraUlp_uid103_fpDivTest_qi <= qDividerProdLTX_uid101_fpDivTest_c and betweenFPwF_uid102_fpDivTest_b;
    extraUlp_uid103_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => extraUlp_uid103_fpDivTest_qi, xout => extraUlp_uid103_fpDivTest_q, clk => clk, aclr => areset );

    -- fracPostRndFT_uid104_fpDivTest(BITSELECT,103)@29
    fracPostRndFT_uid104_fpDivTest_b <= redist34_fracPostRndF_uid80_fpDivTest_q_7_mem_q(31 downto 1);

    -- redist28_fracPostRndFT_uid104_fpDivTest_b_1(DELAY,530)
    redist28_fracPostRndFT_uid104_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracPostRndFT_uid104_fpDivTest_b, xout => redist28_fracPostRndFT_uid104_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- fracRPreExcExt_uid105_fpDivTest(ADD,104)@30
    fracRPreExcExt_uid105_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist28_fracPostRndFT_uid104_fpDivTest_b_1_q);
    fracRPreExcExt_uid105_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000000000000000" & extraUlp_uid103_fpDivTest_q);
    fracRPreExcExt_uid105_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracRPreExcExt_uid105_fpDivTest_a) + UNSIGNED(fracRPreExcExt_uid105_fpDivTest_b));
    fracRPreExcExt_uid105_fpDivTest_q <= fracRPreExcExt_uid105_fpDivTest_o(31 downto 0);

    -- ovfIncRnd_uid109_fpDivTest(BITSELECT,108)@30
    ovfIncRnd_uid109_fpDivTest_b <= STD_LOGIC_VECTOR(fracRPreExcExt_uid105_fpDivTest_q(31 downto 31));

    -- redist27_ovfIncRnd_uid109_fpDivTest_b_1(DELAY,529)
    redist27_ovfIncRnd_uid109_fpDivTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => ovfIncRnd_uid109_fpDivTest_b, xout => redist27_ovfIncRnd_uid109_fpDivTest_b_1_q, clk => clk, aclr => areset );

    -- expFracPostRndInc_uid110_fpDivTest(ADD,109)@31
    expFracPostRndInc_uid110_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist33_expPostRndFR_uid81_fpDivTest_b_9_q);
    expFracPostRndInc_uid110_fpDivTest_b <= STD_LOGIC_VECTOR("00000000" & redist27_ovfIncRnd_uid109_fpDivTest_b_1_q);
    expFracPostRndInc_uid110_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expFracPostRndInc_uid110_fpDivTest_a) + UNSIGNED(expFracPostRndInc_uid110_fpDivTest_b));
    expFracPostRndInc_uid110_fpDivTest_q <= expFracPostRndInc_uid110_fpDivTest_o(8 downto 0);

    -- expFracPostRndR_uid111_fpDivTest(BITSELECT,110)@31
    expFracPostRndR_uid111_fpDivTest_in <= expFracPostRndInc_uid110_fpDivTest_q(7 downto 0);
    expFracPostRndR_uid111_fpDivTest_b <= expFracPostRndR_uid111_fpDivTest_in(7 downto 0);

    -- redist33_expPostRndFR_uid81_fpDivTest_b_9(DELAY,535)
    redist33_expPostRndFR_uid81_fpDivTest_b_9 : dspba_delay
    GENERIC MAP ( width => 8, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist32_expPostRndFR_uid81_fpDivTest_b_5_q, xout => redist33_expPostRndFR_uid81_fpDivTest_b_9_q, clk => clk, aclr => areset );

    -- redist29_extraUlp_uid103_fpDivTest_q_2(DELAY,531)
    redist29_extraUlp_uid103_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => extraUlp_uid103_fpDivTest_q, xout => redist29_extraUlp_uid103_fpDivTest_q_2_q, clk => clk, aclr => areset );

    -- expRPreExc_uid112_fpDivTest(MUX,111)@31
    expRPreExc_uid112_fpDivTest_s <= redist29_extraUlp_uid103_fpDivTest_q_2_q;
    expRPreExc_uid112_fpDivTest_combproc: PROCESS (expRPreExc_uid112_fpDivTest_s, redist33_expPostRndFR_uid81_fpDivTest_b_9_q, expFracPostRndR_uid111_fpDivTest_b)
    BEGIN
        CASE (expRPreExc_uid112_fpDivTest_s) IS
            WHEN "0" => expRPreExc_uid112_fpDivTest_q <= redist33_expPostRndFR_uid81_fpDivTest_b_9_q;
            WHEN "1" => expRPreExc_uid112_fpDivTest_q <= expFracPostRndR_uid111_fpDivTest_b;
            WHEN OTHERS => expRPreExc_uid112_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- invExpXIsMax_uid43_fpDivTest(LOGICAL,42)@22
    invExpXIsMax_uid43_fpDivTest_q <= not (expXIsMax_uid38_fpDivTest_q);

    -- InvExpXIsZero_uid44_fpDivTest(LOGICAL,43)@22
    InvExpXIsZero_uid44_fpDivTest_q <= not (excZ_y_uid37_fpDivTest_q);

    -- excR_y_uid45_fpDivTest(LOGICAL,44)@22
    excR_y_uid45_fpDivTest_q <= InvExpXIsZero_uid44_fpDivTest_q and invExpXIsMax_uid43_fpDivTest_q;

    -- excXIYR_uid127_fpDivTest(LOGICAL,126)@22
    excXIYR_uid127_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excR_y_uid45_fpDivTest_q;

    -- excXIYZ_uid126_fpDivTest(LOGICAL,125)@22
    excXIYZ_uid126_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excZ_y_uid37_fpDivTest_q;

    -- expRExt_uid114_fpDivTest(BITSELECT,113)@22
    expRExt_uid114_fpDivTest_b <= STD_LOGIC_VECTOR(expFracPostRnd_uid76_fpDivTest_q(43 downto 33));

    -- expOvf_uid118_fpDivTest(COMPARE,117)@22
    expOvf_uid118_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid114_fpDivTest_b(10)) & expRExt_uid114_fpDivTest_b));
    expOvf_uid118_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000" & cstAllOWE_uid18_fpDivTest_q));
    expOvf_uid118_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expOvf_uid118_fpDivTest_a) - SIGNED(expOvf_uid118_fpDivTest_b));
    expOvf_uid118_fpDivTest_n(0) <= not (expOvf_uid118_fpDivTest_o(12));

    -- invExpXIsMax_uid29_fpDivTest(LOGICAL,28)@22
    invExpXIsMax_uid29_fpDivTest_q <= not (expXIsMax_uid24_fpDivTest_q);

    -- InvExpXIsZero_uid30_fpDivTest(LOGICAL,29)@22
    InvExpXIsZero_uid30_fpDivTest_q <= not (excZ_x_uid23_fpDivTest_q);

    -- excR_x_uid31_fpDivTest(LOGICAL,30)@22
    excR_x_uid31_fpDivTest_q <= InvExpXIsZero_uid30_fpDivTest_q and invExpXIsMax_uid29_fpDivTest_q;

    -- excXRYROvf_uid125_fpDivTest(LOGICAL,124)@22
    excXRYROvf_uid125_fpDivTest_q <= excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q and expOvf_uid118_fpDivTest_n;

    -- excXRYZ_uid124_fpDivTest(LOGICAL,123)@22
    excXRYZ_uid124_fpDivTest_q <= excR_x_uid31_fpDivTest_q and excZ_y_uid37_fpDivTest_q;

    -- excRInf_uid128_fpDivTest(LOGICAL,127)@22 + 1
    excRInf_uid128_fpDivTest_qi <= excXRYZ_uid124_fpDivTest_q or excXRYROvf_uid125_fpDivTest_q or excXIYZ_uid126_fpDivTest_q or excXIYR_uid127_fpDivTest_q;
    excRInf_uid128_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRInf_uid128_fpDivTest_qi, xout => excRInf_uid128_fpDivTest_q, clk => clk, aclr => areset );

    -- xRegOrZero_uid121_fpDivTest(LOGICAL,120)@22
    xRegOrZero_uid121_fpDivTest_q <= excR_x_uid31_fpDivTest_q or excZ_x_uid23_fpDivTest_q;

    -- regOrZeroOverInf_uid122_fpDivTest(LOGICAL,121)@22 + 1
    regOrZeroOverInf_uid122_fpDivTest_qi <= xRegOrZero_uid121_fpDivTest_q and excI_y_uid41_fpDivTest_q;
    regOrZeroOverInf_uid122_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regOrZeroOverInf_uid122_fpDivTest_qi, xout => regOrZeroOverInf_uid122_fpDivTest_q, clk => clk, aclr => areset );

    -- expUdf_uid115_fpDivTest(COMPARE,114)@22
    expUdf_uid115_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000000000" & GND_q));
    expUdf_uid115_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid114_fpDivTest_b(10)) & expRExt_uid114_fpDivTest_b));
    expUdf_uid115_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expUdf_uid115_fpDivTest_a) - SIGNED(expUdf_uid115_fpDivTest_b));
    expUdf_uid115_fpDivTest_n(0) <= not (expUdf_uid115_fpDivTest_o(12));

    -- regOverRegWithUf_uid120_fpDivTest(LOGICAL,119)@22 + 1
    regOverRegWithUf_uid120_fpDivTest_qi <= expUdf_uid115_fpDivTest_n and excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q;
    regOverRegWithUf_uid120_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => regOverRegWithUf_uid120_fpDivTest_qi, xout => regOverRegWithUf_uid120_fpDivTest_q, clk => clk, aclr => areset );

    -- zeroOverReg_uid119_fpDivTest(LOGICAL,118)@22 + 1
    zeroOverReg_uid119_fpDivTest_qi <= excZ_x_uid23_fpDivTest_q and excR_y_uid45_fpDivTest_q;
    zeroOverReg_uid119_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => zeroOverReg_uid119_fpDivTest_qi, xout => zeroOverReg_uid119_fpDivTest_q, clk => clk, aclr => areset );

    -- excRZero_uid123_fpDivTest(LOGICAL,122)@23
    excRZero_uid123_fpDivTest_q <= zeroOverReg_uid119_fpDivTest_q or regOverRegWithUf_uid120_fpDivTest_q or regOrZeroOverInf_uid122_fpDivTest_q;

    -- concExc_uid132_fpDivTest(BITJOIN,131)@23
    concExc_uid132_fpDivTest_q <= excRNaN_uid131_fpDivTest_q & excRInf_uid128_fpDivTest_q & excRZero_uid123_fpDivTest_q;

    -- excREnc_uid133_fpDivTest(LOOKUP,132)@23 + 1
    excREnc_uid133_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excREnc_uid133_fpDivTest_q <= "01";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (concExc_uid132_fpDivTest_q) IS
                WHEN "000" => excREnc_uid133_fpDivTest_q <= "01";
                WHEN "001" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "010" => excREnc_uid133_fpDivTest_q <= "10";
                WHEN "011" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "100" => excREnc_uid133_fpDivTest_q <= "11";
                WHEN "101" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "110" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "111" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN OTHERS => -- unreachable
                               excREnc_uid133_fpDivTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- redist26_excREnc_uid133_fpDivTest_q_8(DELAY,528)
    redist26_excREnc_uid133_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 2, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => excREnc_uid133_fpDivTest_q, xout => redist26_excREnc_uid133_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- expRPostExc_uid141_fpDivTest(MUX,140)@31
    expRPostExc_uid141_fpDivTest_s <= redist26_excREnc_uid133_fpDivTest_q_8_q;
    expRPostExc_uid141_fpDivTest_combproc: PROCESS (expRPostExc_uid141_fpDivTest_s, cstAllZWE_uid20_fpDivTest_q, expRPreExc_uid112_fpDivTest_q, cstAllOWE_uid18_fpDivTest_q)
    BEGIN
        CASE (expRPostExc_uid141_fpDivTest_s) IS
            WHEN "00" => expRPostExc_uid141_fpDivTest_q <= cstAllZWE_uid20_fpDivTest_q;
            WHEN "01" => expRPostExc_uid141_fpDivTest_q <= expRPreExc_uid112_fpDivTest_q;
            WHEN "10" => expRPostExc_uid141_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN "11" => expRPostExc_uid141_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN OTHERS => expRPostExc_uid141_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid134_fpDivTest(CONSTANT,133)
    oneFracRPostExc2_uid134_fpDivTest_q <= "0000000000000000000000000000001";

    -- fracPostRndFPostUlp_uid106_fpDivTest(BITSELECT,105)@30
    fracPostRndFPostUlp_uid106_fpDivTest_in <= fracRPreExcExt_uid105_fpDivTest_q(30 downto 0);
    fracPostRndFPostUlp_uid106_fpDivTest_b <= fracPostRndFPostUlp_uid106_fpDivTest_in(30 downto 0);

    -- fracRPreExc_uid107_fpDivTest(MUX,106)@30 + 1
    fracRPreExc_uid107_fpDivTest_s <= extraUlp_uid103_fpDivTest_q;
    fracRPreExc_uid107_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPreExc_uid107_fpDivTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRPreExc_uid107_fpDivTest_s) IS
                WHEN "0" => fracRPreExc_uid107_fpDivTest_q <= redist28_fracPostRndFT_uid104_fpDivTest_b_1_q;
                WHEN "1" => fracRPreExc_uid107_fpDivTest_q <= fracPostRndFPostUlp_uid106_fpDivTest_b;
                WHEN OTHERS => fracRPreExc_uid107_fpDivTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- fracRPostExc_uid137_fpDivTest(MUX,136)@31
    fracRPostExc_uid137_fpDivTest_s <= redist26_excREnc_uid133_fpDivTest_q_8_q;
    fracRPostExc_uid137_fpDivTest_combproc: PROCESS (fracRPostExc_uid137_fpDivTest_s, paddingY_uid15_fpDivTest_q, fracRPreExc_uid107_fpDivTest_q, oneFracRPostExc2_uid134_fpDivTest_q)
    BEGIN
        CASE (fracRPostExc_uid137_fpDivTest_s) IS
            WHEN "00" => fracRPostExc_uid137_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "01" => fracRPostExc_uid137_fpDivTest_q <= fracRPreExc_uid107_fpDivTest_q;
            WHEN "10" => fracRPostExc_uid137_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "11" => fracRPostExc_uid137_fpDivTest_q <= oneFracRPostExc2_uid134_fpDivTest_q;
            WHEN OTHERS => fracRPostExc_uid137_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- divR_uid144_fpDivTest(BITJOIN,143)@31
    divR_uid144_fpDivTest_q <= redist25_sRPostExc_uid143_fpDivTest_q_8_q & expRPostExc_uid141_fpDivTest_q & fracRPostExc_uid137_fpDivTest_q;

    -- xOut(GPOUT,4)@31
    q <= divR_uid144_fpDivTest_q;

END normal;
