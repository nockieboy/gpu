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

-- VHDL created from MULT40_0002
-- VHDL created on Wed Oct 19 18:39:43 2022


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

entity MULT40_0002 is
    port (
        a : in std_logic_vector(39 downto 0);  -- float40_m31
        b : in std_logic_vector(39 downto 0);  -- float40_m31
        q : out std_logic_vector(39 downto 0);  -- float40_m31
        clk : in std_logic;
        areset : in std_logic
    );
end MULT40_0002;

architecture normal of MULT40_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expX_uid6_fpMulTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expY_uid7_fpMulTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal signX_uid8_fpMulTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal signY_uid9_fpMulTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid10_fpMulTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid11_fpMulTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal cstAllZWE_uid12_fpMulTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_x_uid14_fpMulTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal excZ_x_uid15_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_x_uid15_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid16_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid16_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid17_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid17_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid18_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid19_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid20_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid21_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid22_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid23_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal frac_y_uid28_fpMulTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal excZ_y_uid29_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid29_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid30_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid30_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid31_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid31_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid32_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid33_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid34_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid35_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid36_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid37_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal ofracX_uid40_fpMulTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal ofracY_uid43_fpMulTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal expSum_uid44_fpMulTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expSum_uid44_fpMulTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expSum_uid44_fpMulTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expSum_uid44_fpMulTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal biasInc_uid45_fpMulTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expSumMBias_uid46_fpMulTest_a : STD_LOGIC_VECTOR (11 downto 0);
    signal expSumMBias_uid46_fpMulTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal expSumMBias_uid46_fpMulTest_o : STD_LOGIC_VECTOR (11 downto 0);
    signal expSumMBias_uid46_fpMulTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal signR_uid48_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid48_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal normalizeBit_uid49_fpMulTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPostNormHigh_uid51_fpMulTest_in : STD_LOGIC_VECTOR (62 downto 0);
    signal fracRPostNormHigh_uid51_fpMulTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPostNormLow_uid52_fpMulTest_in : STD_LOGIC_VECTOR (61 downto 0);
    signal fracRPostNormLow_uid52_fpMulTest_b : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPostNorm_uid53_fpMulTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPostNorm_uid53_fpMulTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal stickyRange_uid54_fpMulTest_in : STD_LOGIC_VECTOR (29 downto 0);
    signal stickyRange_uid54_fpMulTest_b : STD_LOGIC_VECTOR (29 downto 0);
    signal extraStickyBitOfProd_uid55_fpMulTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal extraStickyBitOfProd_uid55_fpMulTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal extraStickyBit_uid56_fpMulTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal extraStickyBit_uid56_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal stickyExtendedRange_uid57_fpMulTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal stickyRangeComparator_uid59_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal stickyRangeComparator_uid59_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sticky_uid60_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPostNorm1dto0_uid61_fpMulTest_in : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostNorm1dto0_uid61_fpMulTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal lrs_uid62_fpMulTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal roundBitDetectionConstant_uid63_fpMulTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal roundBitDetectionPattern_uid64_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal roundBit_uid65_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracPreRound_uid66_fpMulTest_q : STD_LOGIC_VECTOR (42 downto 0);
    signal roundBitAndNormalizationOp_uid68_fpMulTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal expFracRPostRounding_uid69_fpMulTest_a : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracRPostRounding_uid69_fpMulTest_b : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracRPostRounding_uid69_fpMulTest_o : STD_LOGIC_VECTOR (44 downto 0);
    signal expFracRPostRounding_uid69_fpMulTest_q : STD_LOGIC_VECTOR (43 downto 0);
    signal fracRPreExc_uid70_fpMulTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPreExc_uid70_fpMulTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPreExcExt_uid71_fpMulTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal expRPreExc_uid72_fpMulTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal expRPreExc_uid72_fpMulTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expUdf_uid73_fpMulTest_a : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid73_fpMulTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid73_fpMulTest_o : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid73_fpMulTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid75_fpMulTest_a : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid75_fpMulTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid75_fpMulTest_o : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid75_fpMulTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZAndExcYZ_uid76_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZAndExcYR_uid77_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excYZAndExcXR_uid78_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZC3_uid79_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid80_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid80_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIAndExcYI_uid81_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRAndExcYI_uid82_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excYRAndExcXI_uid83_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal ExcROvfAndInReg_uid84_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid85_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid85_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excYZAndExcXI_uid86_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZAndExcYI_uid87_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal ZeroTimesInf_uid88_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid89_fpMulTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid89_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid90_fpMulTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid91_fpMulTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oneFracRPostExc2_uid92_fpMulTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal fracRPostExc_uid95_fpMulTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid95_fpMulTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expRPostExc_uid100_fpMulTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid100_fpMulTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invExcRNaN_uid101_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid102_fpMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal R_uid103_fpMulTest_q : STD_LOGIC_VECTOR (39 downto 0);
    signal osig_uid106_prod_uid47_fpMulTest_in : STD_LOGIC_VECTOR (63 downto 0);
    signal osig_uid106_prod_uid47_fpMulTest_b : STD_LOGIC_VECTOR (63 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im0_a0 : STD_LOGIC_VECTOR (14 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im0_b0 : STD_LOGIC_VECTOR (14 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im0_s1 : STD_LOGIC_VECTOR (29 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im0_reset : std_logic;
    signal prodXY_uid105_prod_uid47_fpMulTest_im0_q : STD_LOGIC_VECTOR (29 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs1_b : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bjA2_q : STD_LOGIC_VECTOR (14 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs3_b : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bjB4_q : STD_LOGIC_VECTOR (14 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im5_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im5_b0 : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im5_s1 : STD_LOGIC_VECTOR (31 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im5_reset : std_logic;
    signal prodXY_uid105_prod_uid47_fpMulTest_im5_q : STD_LOGIC_VECTOR (31 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs6_in : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs6_b : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs7_b : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im8_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im8_b0 : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im8_s1 : STD_LOGIC_VECTOR (31 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im8_reset : std_logic;
    signal prodXY_uid105_prod_uid47_fpMulTest_im8_q : STD_LOGIC_VECTOR (31 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs9_b : STD_LOGIC_VECTOR (13 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs10_in : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_bs10_b : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im11_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im11_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im11_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_im11_reset : std_logic;
    signal prodXY_uid105_prod_uid47_fpMulTest_im11_q : STD_LOGIC_VECTOR (35 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_join_14_q : STD_LOGIC_VECTOR (65 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_align_15_q : STD_LOGIC_VECTOR (49 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_align_15_qint : STD_LOGIC_VECTOR (49 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_align_17_q : STD_LOGIC_VECTOR (49 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_align_17_qint : STD_LOGIC_VECTOR (49 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_a : STD_LOGIC_VECTOR (67 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_b : STD_LOGIC_VECTOR (67 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_o : STD_LOGIC_VECTOR (67 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_q : STD_LOGIC_VECTOR (66 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_a : STD_LOGIC_VECTOR (68 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_b : STD_LOGIC_VECTOR (68 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_o : STD_LOGIC_VECTOR (68 downto 0);
    signal prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_q : STD_LOGIC_VECTOR (67 downto 0);
    signal redist0_prodXY_uid105_prod_uid47_fpMulTest_im11_q_1_q : STD_LOGIC_VECTOR (35 downto 0);
    signal redist1_prodXY_uid105_prod_uid47_fpMulTest_bs10_b_1_q : STD_LOGIC_VECTOR (17 downto 0);
    signal redist2_prodXY_uid105_prod_uid47_fpMulTest_bs9_b_1_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist3_prodXY_uid105_prod_uid47_fpMulTest_im8_q_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist4_prodXY_uid105_prod_uid47_fpMulTest_im5_q_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist5_prodXY_uid105_prod_uid47_fpMulTest_im0_q_1_q : STD_LOGIC_VECTOR (29 downto 0);
    signal redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q : STD_LOGIC_VECTOR (63 downto 0);
    signal redist7_expRPreExc_uid72_fpMulTest_b_1_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist8_expRPreExcExt_uid71_fpMulTest_b_1_q : STD_LOGIC_VECTOR (11 downto 0);
    signal redist9_fracRPreExc_uid70_fpMulTest_b_2_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist10_normalizeBit_uid49_fpMulTest_b_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist11_signR_uid48_fpMulTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_expSum_uid44_fpMulTest_q_5_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist13_fracXIsZero_uid31_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_expXIsMax_uid30_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist15_excZ_y_uid29_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist16_fracXIsZero_uid17_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist17_expXIsMax_uid16_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist18_excZ_x_uid15_fpMulTest_q_7_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- frac_x_uid14_fpMulTest(BITSELECT,13)@0
    frac_x_uid14_fpMulTest_b <= a(30 downto 0);

    -- cstZeroWF_uid11_fpMulTest(CONSTANT,10)
    cstZeroWF_uid11_fpMulTest_q <= "0000000000000000000000000000000";

    -- fracXIsZero_uid17_fpMulTest(LOGICAL,16)@0 + 1
    fracXIsZero_uid17_fpMulTest_qi <= "1" WHEN cstZeroWF_uid11_fpMulTest_q = frac_x_uid14_fpMulTest_b ELSE "0";
    fracXIsZero_uid17_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid17_fpMulTest_qi, xout => fracXIsZero_uid17_fpMulTest_q, clk => clk, aclr => areset );

    -- redist16_fracXIsZero_uid17_fpMulTest_q_7(DELAY,144)
    redist16_fracXIsZero_uid17_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid17_fpMulTest_q, xout => redist16_fracXIsZero_uid17_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid10_fpMulTest(CONSTANT,9)
    cstAllOWE_uid10_fpMulTest_q <= "11111111";

    -- expX_uid6_fpMulTest(BITSELECT,5)@0
    expX_uid6_fpMulTest_b <= a(38 downto 31);

    -- expXIsMax_uid16_fpMulTest(LOGICAL,15)@0 + 1
    expXIsMax_uid16_fpMulTest_qi <= "1" WHEN expX_uid6_fpMulTest_b = cstAllOWE_uid10_fpMulTest_q ELSE "0";
    expXIsMax_uid16_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid16_fpMulTest_qi, xout => expXIsMax_uid16_fpMulTest_q, clk => clk, aclr => areset );

    -- redist17_expXIsMax_uid16_fpMulTest_q_7(DELAY,145)
    redist17_expXIsMax_uid16_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid16_fpMulTest_q, xout => redist17_expXIsMax_uid16_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- excI_x_uid19_fpMulTest(LOGICAL,18)@7
    excI_x_uid19_fpMulTest_q <= redist17_expXIsMax_uid16_fpMulTest_q_7_q and redist16_fracXIsZero_uid17_fpMulTest_q_7_q;

    -- cstAllZWE_uid12_fpMulTest(CONSTANT,11)
    cstAllZWE_uid12_fpMulTest_q <= "00000000";

    -- expY_uid7_fpMulTest(BITSELECT,6)@0
    expY_uid7_fpMulTest_b <= b(38 downto 31);

    -- excZ_y_uid29_fpMulTest(LOGICAL,28)@0 + 1
    excZ_y_uid29_fpMulTest_qi <= "1" WHEN expY_uid7_fpMulTest_b = cstAllZWE_uid12_fpMulTest_q ELSE "0";
    excZ_y_uid29_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid29_fpMulTest_qi, xout => excZ_y_uid29_fpMulTest_q, clk => clk, aclr => areset );

    -- redist15_excZ_y_uid29_fpMulTest_q_7(DELAY,143)
    redist15_excZ_y_uid29_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid29_fpMulTest_q, xout => redist15_excZ_y_uid29_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- excYZAndExcXI_uid86_fpMulTest(LOGICAL,85)@7
    excYZAndExcXI_uid86_fpMulTest_q <= redist15_excZ_y_uid29_fpMulTest_q_7_q and excI_x_uid19_fpMulTest_q;

    -- frac_y_uid28_fpMulTest(BITSELECT,27)@0
    frac_y_uid28_fpMulTest_b <= b(30 downto 0);

    -- fracXIsZero_uid31_fpMulTest(LOGICAL,30)@0 + 1
    fracXIsZero_uid31_fpMulTest_qi <= "1" WHEN cstZeroWF_uid11_fpMulTest_q = frac_y_uid28_fpMulTest_b ELSE "0";
    fracXIsZero_uid31_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid31_fpMulTest_qi, xout => fracXIsZero_uid31_fpMulTest_q, clk => clk, aclr => areset );

    -- redist13_fracXIsZero_uid31_fpMulTest_q_7(DELAY,141)
    redist13_fracXIsZero_uid31_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid31_fpMulTest_q, xout => redist13_fracXIsZero_uid31_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- expXIsMax_uid30_fpMulTest(LOGICAL,29)@0 + 1
    expXIsMax_uid30_fpMulTest_qi <= "1" WHEN expY_uid7_fpMulTest_b = cstAllOWE_uid10_fpMulTest_q ELSE "0";
    expXIsMax_uid30_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid30_fpMulTest_qi, xout => expXIsMax_uid30_fpMulTest_q, clk => clk, aclr => areset );

    -- redist14_expXIsMax_uid30_fpMulTest_q_7(DELAY,142)
    redist14_expXIsMax_uid30_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid30_fpMulTest_q, xout => redist14_expXIsMax_uid30_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- excI_y_uid33_fpMulTest(LOGICAL,32)@7
    excI_y_uid33_fpMulTest_q <= redist14_expXIsMax_uid30_fpMulTest_q_7_q and redist13_fracXIsZero_uid31_fpMulTest_q_7_q;

    -- excZ_x_uid15_fpMulTest(LOGICAL,14)@0 + 1
    excZ_x_uid15_fpMulTest_qi <= "1" WHEN expX_uid6_fpMulTest_b = cstAllZWE_uid12_fpMulTest_q ELSE "0";
    excZ_x_uid15_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid15_fpMulTest_qi, xout => excZ_x_uid15_fpMulTest_q, clk => clk, aclr => areset );

    -- redist18_excZ_x_uid15_fpMulTest_q_7(DELAY,146)
    redist18_excZ_x_uid15_fpMulTest_q_7 : dspba_delay
    GENERIC MAP ( width => 1, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid15_fpMulTest_q, xout => redist18_excZ_x_uid15_fpMulTest_q_7_q, clk => clk, aclr => areset );

    -- excXZAndExcYI_uid87_fpMulTest(LOGICAL,86)@7
    excXZAndExcYI_uid87_fpMulTest_q <= redist18_excZ_x_uid15_fpMulTest_q_7_q and excI_y_uid33_fpMulTest_q;

    -- ZeroTimesInf_uid88_fpMulTest(LOGICAL,87)@7
    ZeroTimesInf_uid88_fpMulTest_q <= excXZAndExcYI_uid87_fpMulTest_q or excYZAndExcXI_uid86_fpMulTest_q;

    -- fracXIsNotZero_uid32_fpMulTest(LOGICAL,31)@7
    fracXIsNotZero_uid32_fpMulTest_q <= not (redist13_fracXIsZero_uid31_fpMulTest_q_7_q);

    -- excN_y_uid34_fpMulTest(LOGICAL,33)@7
    excN_y_uid34_fpMulTest_q <= redist14_expXIsMax_uid30_fpMulTest_q_7_q and fracXIsNotZero_uid32_fpMulTest_q;

    -- fracXIsNotZero_uid18_fpMulTest(LOGICAL,17)@7
    fracXIsNotZero_uid18_fpMulTest_q <= not (redist16_fracXIsZero_uid17_fpMulTest_q_7_q);

    -- excN_x_uid20_fpMulTest(LOGICAL,19)@7
    excN_x_uid20_fpMulTest_q <= redist17_expXIsMax_uid16_fpMulTest_q_7_q and fracXIsNotZero_uid18_fpMulTest_q;

    -- excRNaN_uid89_fpMulTest(LOGICAL,88)@7 + 1
    excRNaN_uid89_fpMulTest_qi <= excN_x_uid20_fpMulTest_q or excN_y_uid34_fpMulTest_q or ZeroTimesInf_uid88_fpMulTest_q;
    excRNaN_uid89_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRNaN_uid89_fpMulTest_qi, xout => excRNaN_uid89_fpMulTest_q, clk => clk, aclr => areset );

    -- invExcRNaN_uid101_fpMulTest(LOGICAL,100)@8
    invExcRNaN_uid101_fpMulTest_q <= not (excRNaN_uid89_fpMulTest_q);

    -- signY_uid9_fpMulTest(BITSELECT,8)@0
    signY_uid9_fpMulTest_b <= STD_LOGIC_VECTOR(b(39 downto 39));

    -- signX_uid8_fpMulTest(BITSELECT,7)@0
    signX_uid8_fpMulTest_b <= STD_LOGIC_VECTOR(a(39 downto 39));

    -- signR_uid48_fpMulTest(LOGICAL,47)@0 + 1
    signR_uid48_fpMulTest_qi <= signX_uid8_fpMulTest_b xor signY_uid9_fpMulTest_b;
    signR_uid48_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid48_fpMulTest_qi, xout => signR_uid48_fpMulTest_q, clk => clk, aclr => areset );

    -- redist11_signR_uid48_fpMulTest_q_8(DELAY,139)
    redist11_signR_uid48_fpMulTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid48_fpMulTest_q, xout => redist11_signR_uid48_fpMulTest_q_8_q, clk => clk, aclr => areset );

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- signRPostExc_uid102_fpMulTest(LOGICAL,101)@8
    signRPostExc_uid102_fpMulTest_q <= redist11_signR_uid48_fpMulTest_q_8_q and invExcRNaN_uid101_fpMulTest_q;

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- ofracX_uid40_fpMulTest(BITJOIN,39)@0
    ofracX_uid40_fpMulTest_q <= VCC_q & frac_x_uid14_fpMulTest_b;

    -- prodXY_uid105_prod_uid47_fpMulTest_bs9(BITSELECT,116)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs9_b <= ofracX_uid40_fpMulTest_q(31 downto 18);

    -- redist2_prodXY_uid105_prod_uid47_fpMulTest_bs9_b_1(DELAY,130)
    redist2_prodXY_uid105_prod_uid47_fpMulTest_bs9_b_1 : dspba_delay
    GENERIC MAP ( width => 14, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_bs9_b, xout => redist2_prodXY_uid105_prod_uid47_fpMulTest_bs9_b_1_q, clk => clk, aclr => areset );

    -- ofracY_uid43_fpMulTest(BITJOIN,42)@0
    ofracY_uid43_fpMulTest_q <= VCC_q & frac_y_uid28_fpMulTest_b;

    -- prodXY_uid105_prod_uid47_fpMulTest_bs10(BITSELECT,117)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs10_in <= ofracY_uid43_fpMulTest_q(17 downto 0);
    prodXY_uid105_prod_uid47_fpMulTest_bs10_b <= prodXY_uid105_prod_uid47_fpMulTest_bs10_in(17 downto 0);

    -- redist1_prodXY_uid105_prod_uid47_fpMulTest_bs10_b_1(DELAY,129)
    redist1_prodXY_uid105_prod_uid47_fpMulTest_bs10_b_1 : dspba_delay
    GENERIC MAP ( width => 18, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_bs10_b, xout => redist1_prodXY_uid105_prod_uid47_fpMulTest_bs10_b_1_q, clk => clk, aclr => areset );

    -- prodXY_uid105_prod_uid47_fpMulTest_im8(MULT,115)@1 + 2
    prodXY_uid105_prod_uid47_fpMulTest_im8_a0 <= redist1_prodXY_uid105_prod_uid47_fpMulTest_bs10_b_1_q;
    prodXY_uid105_prod_uid47_fpMulTest_im8_b0 <= redist2_prodXY_uid105_prod_uid47_fpMulTest_bs9_b_1_q;
    prodXY_uid105_prod_uid47_fpMulTest_im8_reset <= areset;
    prodXY_uid105_prod_uid47_fpMulTest_im8_component : lpm_mult
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
        dataa => prodXY_uid105_prod_uid47_fpMulTest_im8_a0,
        datab => prodXY_uid105_prod_uid47_fpMulTest_im8_b0,
        clken => VCC_q(0),
        aclr => prodXY_uid105_prod_uid47_fpMulTest_im8_reset,
        clock => clk,
        result => prodXY_uid105_prod_uid47_fpMulTest_im8_s1
    );
    prodXY_uid105_prod_uid47_fpMulTest_im8_q <= prodXY_uid105_prod_uid47_fpMulTest_im8_s1;

    -- redist3_prodXY_uid105_prod_uid47_fpMulTest_im8_q_1(DELAY,131)
    redist3_prodXY_uid105_prod_uid47_fpMulTest_im8_q_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_im8_q, xout => redist3_prodXY_uid105_prod_uid47_fpMulTest_im8_q_1_q, clk => clk, aclr => areset );

    -- prodXY_uid105_prod_uid47_fpMulTest_align_17(BITSHIFT,124)@4
    prodXY_uid105_prod_uid47_fpMulTest_align_17_qint <= redist3_prodXY_uid105_prod_uid47_fpMulTest_im8_q_1_q & "000000000000000000";
    prodXY_uid105_prod_uid47_fpMulTest_align_17_q <= prodXY_uid105_prod_uid47_fpMulTest_align_17_qint(49 downto 0);

    -- prodXY_uid105_prod_uid47_fpMulTest_bs7(BITSELECT,114)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs7_b <= ofracY_uid43_fpMulTest_q(31 downto 18);

    -- prodXY_uid105_prod_uid47_fpMulTest_bs6(BITSELECT,113)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs6_in <= ofracX_uid40_fpMulTest_q(17 downto 0);
    prodXY_uid105_prod_uid47_fpMulTest_bs6_b <= prodXY_uid105_prod_uid47_fpMulTest_bs6_in(17 downto 0);

    -- prodXY_uid105_prod_uid47_fpMulTest_im5(MULT,112)@0 + 2
    prodXY_uid105_prod_uid47_fpMulTest_im5_a0 <= prodXY_uid105_prod_uid47_fpMulTest_bs6_b;
    prodXY_uid105_prod_uid47_fpMulTest_im5_b0 <= prodXY_uid105_prod_uid47_fpMulTest_bs7_b;
    prodXY_uid105_prod_uid47_fpMulTest_im5_reset <= areset;
    prodXY_uid105_prod_uid47_fpMulTest_im5_component : lpm_mult
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
        dataa => prodXY_uid105_prod_uid47_fpMulTest_im5_a0,
        datab => prodXY_uid105_prod_uid47_fpMulTest_im5_b0,
        clken => VCC_q(0),
        aclr => prodXY_uid105_prod_uid47_fpMulTest_im5_reset,
        clock => clk,
        result => prodXY_uid105_prod_uid47_fpMulTest_im5_s1
    );
    prodXY_uid105_prod_uid47_fpMulTest_im5_q <= prodXY_uid105_prod_uid47_fpMulTest_im5_s1;

    -- redist4_prodXY_uid105_prod_uid47_fpMulTest_im5_q_1(DELAY,132)
    redist4_prodXY_uid105_prod_uid47_fpMulTest_im5_q_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_im5_q, xout => redist4_prodXY_uid105_prod_uid47_fpMulTest_im5_q_1_q, clk => clk, aclr => areset );

    -- prodXY_uid105_prod_uid47_fpMulTest_align_15(BITSHIFT,122)@3
    prodXY_uid105_prod_uid47_fpMulTest_align_15_qint <= redist4_prodXY_uid105_prod_uid47_fpMulTest_im5_q_1_q & "000000000000000000";
    prodXY_uid105_prod_uid47_fpMulTest_align_15_q <= prodXY_uid105_prod_uid47_fpMulTest_align_15_qint(49 downto 0);

    -- prodXY_uid105_prod_uid47_fpMulTest_bs3(BITSELECT,110)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs3_b <= STD_LOGIC_VECTOR(ofracY_uid43_fpMulTest_q(31 downto 18));

    -- prodXY_uid105_prod_uid47_fpMulTest_bjB4(BITJOIN,111)@0
    prodXY_uid105_prod_uid47_fpMulTest_bjB4_q <= GND_q & prodXY_uid105_prod_uid47_fpMulTest_bs3_b;

    -- prodXY_uid105_prod_uid47_fpMulTest_bs1(BITSELECT,108)@0
    prodXY_uid105_prod_uid47_fpMulTest_bs1_b <= STD_LOGIC_VECTOR(ofracX_uid40_fpMulTest_q(31 downto 18));

    -- prodXY_uid105_prod_uid47_fpMulTest_bjA2(BITJOIN,109)@0
    prodXY_uid105_prod_uid47_fpMulTest_bjA2_q <= GND_q & prodXY_uid105_prod_uid47_fpMulTest_bs1_b;

    -- prodXY_uid105_prod_uid47_fpMulTest_im0(MULT,107)@0 + 2
    prodXY_uid105_prod_uid47_fpMulTest_im0_a0 <= STD_LOGIC_VECTOR(prodXY_uid105_prod_uid47_fpMulTest_bjA2_q);
    prodXY_uid105_prod_uid47_fpMulTest_im0_b0 <= STD_LOGIC_VECTOR(prodXY_uid105_prod_uid47_fpMulTest_bjB4_q);
    prodXY_uid105_prod_uid47_fpMulTest_im0_reset <= areset;
    prodXY_uid105_prod_uid47_fpMulTest_im0_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 15,
        lpm_widthb => 15,
        lpm_widthp => 30,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => prodXY_uid105_prod_uid47_fpMulTest_im0_a0,
        datab => prodXY_uid105_prod_uid47_fpMulTest_im0_b0,
        clken => VCC_q(0),
        aclr => prodXY_uid105_prod_uid47_fpMulTest_im0_reset,
        clock => clk,
        result => prodXY_uid105_prod_uid47_fpMulTest_im0_s1
    );
    prodXY_uid105_prod_uid47_fpMulTest_im0_q <= prodXY_uid105_prod_uid47_fpMulTest_im0_s1;

    -- redist5_prodXY_uid105_prod_uid47_fpMulTest_im0_q_1(DELAY,133)
    redist5_prodXY_uid105_prod_uid47_fpMulTest_im0_q_1 : dspba_delay
    GENERIC MAP ( width => 30, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_im0_q, xout => redist5_prodXY_uid105_prod_uid47_fpMulTest_im0_q_1_q, clk => clk, aclr => areset );

    -- prodXY_uid105_prod_uid47_fpMulTest_im11(MULT,118)@0 + 2
    prodXY_uid105_prod_uid47_fpMulTest_im11_a0 <= prodXY_uid105_prod_uid47_fpMulTest_bs6_b;
    prodXY_uid105_prod_uid47_fpMulTest_im11_b0 <= prodXY_uid105_prod_uid47_fpMulTest_bs10_b;
    prodXY_uid105_prod_uid47_fpMulTest_im11_reset <= areset;
    prodXY_uid105_prod_uid47_fpMulTest_im11_component : lpm_mult
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
        dataa => prodXY_uid105_prod_uid47_fpMulTest_im11_a0,
        datab => prodXY_uid105_prod_uid47_fpMulTest_im11_b0,
        clken => VCC_q(0),
        aclr => prodXY_uid105_prod_uid47_fpMulTest_im11_reset,
        clock => clk,
        result => prodXY_uid105_prod_uid47_fpMulTest_im11_s1
    );
    prodXY_uid105_prod_uid47_fpMulTest_im11_q <= prodXY_uid105_prod_uid47_fpMulTest_im11_s1;

    -- redist0_prodXY_uid105_prod_uid47_fpMulTest_im11_q_1(DELAY,128)
    redist0_prodXY_uid105_prod_uid47_fpMulTest_im11_q_1 : dspba_delay
    GENERIC MAP ( width => 36, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => prodXY_uid105_prod_uid47_fpMulTest_im11_q, xout => redist0_prodXY_uid105_prod_uid47_fpMulTest_im11_q_1_q, clk => clk, aclr => areset );

    -- prodXY_uid105_prod_uid47_fpMulTest_join_14(BITJOIN,121)@3
    prodXY_uid105_prod_uid47_fpMulTest_join_14_q <= redist5_prodXY_uid105_prod_uid47_fpMulTest_im0_q_1_q & redist0_prodXY_uid105_prod_uid47_fpMulTest_im11_q_1_q;

    -- prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0(ADD,126)@3 + 1
    prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((67 downto 66 => prodXY_uid105_prod_uid47_fpMulTest_join_14_q(65)) & prodXY_uid105_prod_uid47_fpMulTest_join_14_q));
    prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000000000000000" & prodXY_uid105_prod_uid47_fpMulTest_align_15_q));
    prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_o <= STD_LOGIC_VECTOR(SIGNED(prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_a) + SIGNED(prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_b));
        END IF;
    END PROCESS;
    prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_q <= prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_o(66 downto 0);

    -- prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0(ADD,127)@4
    prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((68 downto 67 => prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_q(66)) & prodXY_uid105_prod_uid47_fpMulTest_result_add_0_0_q));
    prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0000000000000000000" & prodXY_uid105_prod_uid47_fpMulTest_align_17_q));
    prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_o <= STD_LOGIC_VECTOR(SIGNED(prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_a) + SIGNED(prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_b));
    prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_q <= prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_o(67 downto 0);

    -- osig_uid106_prod_uid47_fpMulTest(BITSELECT,105)@4
    osig_uid106_prod_uid47_fpMulTest_in <= prodXY_uid105_prod_uid47_fpMulTest_result_add_1_0_q(63 downto 0);
    osig_uid106_prod_uid47_fpMulTest_b <= osig_uid106_prod_uid47_fpMulTest_in(63 downto 0);

    -- redist6_osig_uid106_prod_uid47_fpMulTest_b_1(DELAY,134)
    redist6_osig_uid106_prod_uid47_fpMulTest_b_1 : dspba_delay
    GENERIC MAP ( width => 64, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => osig_uid106_prod_uid47_fpMulTest_b, xout => redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q, clk => clk, aclr => areset );

    -- normalizeBit_uid49_fpMulTest(BITSELECT,48)@5
    normalizeBit_uid49_fpMulTest_b <= STD_LOGIC_VECTOR(redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q(63 downto 63));

    -- redist10_normalizeBit_uid49_fpMulTest_b_1(DELAY,138)
    redist10_normalizeBit_uid49_fpMulTest_b_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => normalizeBit_uid49_fpMulTest_b, xout => redist10_normalizeBit_uid49_fpMulTest_b_1_q, clk => clk, aclr => areset );

    -- roundBitDetectionConstant_uid63_fpMulTest(CONSTANT,62)
    roundBitDetectionConstant_uid63_fpMulTest_q <= "010";

    -- fracRPostNormHigh_uid51_fpMulTest(BITSELECT,50)@5
    fracRPostNormHigh_uid51_fpMulTest_in <= redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q(62 downto 0);
    fracRPostNormHigh_uid51_fpMulTest_b <= fracRPostNormHigh_uid51_fpMulTest_in(62 downto 31);

    -- fracRPostNormLow_uid52_fpMulTest(BITSELECT,51)@5
    fracRPostNormLow_uid52_fpMulTest_in <= redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q(61 downto 0);
    fracRPostNormLow_uid52_fpMulTest_b <= fracRPostNormLow_uid52_fpMulTest_in(61 downto 30);

    -- fracRPostNorm_uid53_fpMulTest(MUX,52)@5 + 1
    fracRPostNorm_uid53_fpMulTest_s <= normalizeBit_uid49_fpMulTest_b;
    fracRPostNorm_uid53_fpMulTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPostNorm_uid53_fpMulTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRPostNorm_uid53_fpMulTest_s) IS
                WHEN "0" => fracRPostNorm_uid53_fpMulTest_q <= fracRPostNormLow_uid52_fpMulTest_b;
                WHEN "1" => fracRPostNorm_uid53_fpMulTest_q <= fracRPostNormHigh_uid51_fpMulTest_b;
                WHEN OTHERS => fracRPostNorm_uid53_fpMulTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- fracRPostNorm1dto0_uid61_fpMulTest(BITSELECT,60)@6
    fracRPostNorm1dto0_uid61_fpMulTest_in <= fracRPostNorm_uid53_fpMulTest_q(1 downto 0);
    fracRPostNorm1dto0_uid61_fpMulTest_b <= fracRPostNorm1dto0_uid61_fpMulTest_in(1 downto 0);

    -- extraStickyBitOfProd_uid55_fpMulTest(BITSELECT,54)@5
    extraStickyBitOfProd_uid55_fpMulTest_in <= STD_LOGIC_VECTOR(redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q(30 downto 0));
    extraStickyBitOfProd_uid55_fpMulTest_b <= STD_LOGIC_VECTOR(extraStickyBitOfProd_uid55_fpMulTest_in(30 downto 30));

    -- extraStickyBit_uid56_fpMulTest(MUX,55)@5
    extraStickyBit_uid56_fpMulTest_s <= normalizeBit_uid49_fpMulTest_b;
    extraStickyBit_uid56_fpMulTest_combproc: PROCESS (extraStickyBit_uid56_fpMulTest_s, GND_q, extraStickyBitOfProd_uid55_fpMulTest_b)
    BEGIN
        CASE (extraStickyBit_uid56_fpMulTest_s) IS
            WHEN "0" => extraStickyBit_uid56_fpMulTest_q <= GND_q;
            WHEN "1" => extraStickyBit_uid56_fpMulTest_q <= extraStickyBitOfProd_uid55_fpMulTest_b;
            WHEN OTHERS => extraStickyBit_uid56_fpMulTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- stickyRange_uid54_fpMulTest(BITSELECT,53)@5
    stickyRange_uid54_fpMulTest_in <= redist6_osig_uid106_prod_uid47_fpMulTest_b_1_q(29 downto 0);
    stickyRange_uid54_fpMulTest_b <= stickyRange_uid54_fpMulTest_in(29 downto 0);

    -- stickyExtendedRange_uid57_fpMulTest(BITJOIN,56)@5
    stickyExtendedRange_uid57_fpMulTest_q <= extraStickyBit_uid56_fpMulTest_q & stickyRange_uid54_fpMulTest_b;

    -- stickyRangeComparator_uid59_fpMulTest(LOGICAL,58)@5 + 1
    stickyRangeComparator_uid59_fpMulTest_qi <= "1" WHEN stickyExtendedRange_uid57_fpMulTest_q = cstZeroWF_uid11_fpMulTest_q ELSE "0";
    stickyRangeComparator_uid59_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => stickyRangeComparator_uid59_fpMulTest_qi, xout => stickyRangeComparator_uid59_fpMulTest_q, clk => clk, aclr => areset );

    -- sticky_uid60_fpMulTest(LOGICAL,59)@6
    sticky_uid60_fpMulTest_q <= not (stickyRangeComparator_uid59_fpMulTest_q);

    -- lrs_uid62_fpMulTest(BITJOIN,61)@6
    lrs_uid62_fpMulTest_q <= fracRPostNorm1dto0_uid61_fpMulTest_b & sticky_uid60_fpMulTest_q;

    -- roundBitDetectionPattern_uid64_fpMulTest(LOGICAL,63)@6
    roundBitDetectionPattern_uid64_fpMulTest_q <= "1" WHEN lrs_uid62_fpMulTest_q = roundBitDetectionConstant_uid63_fpMulTest_q ELSE "0";

    -- roundBit_uid65_fpMulTest(LOGICAL,64)@6
    roundBit_uid65_fpMulTest_q <= not (roundBitDetectionPattern_uid64_fpMulTest_q);

    -- roundBitAndNormalizationOp_uid68_fpMulTest(BITJOIN,67)@6
    roundBitAndNormalizationOp_uid68_fpMulTest_q <= GND_q & redist10_normalizeBit_uid49_fpMulTest_b_1_q & cstZeroWF_uid11_fpMulTest_q & roundBit_uid65_fpMulTest_q;

    -- biasInc_uid45_fpMulTest(CONSTANT,44)
    biasInc_uid45_fpMulTest_q <= "0001111111";

    -- expSum_uid44_fpMulTest(ADD,43)@0 + 1
    expSum_uid44_fpMulTest_a <= STD_LOGIC_VECTOR("0" & expX_uid6_fpMulTest_b);
    expSum_uid44_fpMulTest_b <= STD_LOGIC_VECTOR("0" & expY_uid7_fpMulTest_b);
    expSum_uid44_fpMulTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expSum_uid44_fpMulTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expSum_uid44_fpMulTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expSum_uid44_fpMulTest_a) + UNSIGNED(expSum_uid44_fpMulTest_b));
        END IF;
    END PROCESS;
    expSum_uid44_fpMulTest_q <= expSum_uid44_fpMulTest_o(8 downto 0);

    -- redist12_expSum_uid44_fpMulTest_q_5(DELAY,140)
    redist12_expSum_uid44_fpMulTest_q_5 : dspba_delay
    GENERIC MAP ( width => 9, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => expSum_uid44_fpMulTest_q, xout => redist12_expSum_uid44_fpMulTest_q_5_q, clk => clk, aclr => areset );

    -- expSumMBias_uid46_fpMulTest(SUB,45)@5 + 1
    expSumMBias_uid46_fpMulTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & redist12_expSum_uid44_fpMulTest_q_5_q));
    expSumMBias_uid46_fpMulTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 10 => biasInc_uid45_fpMulTest_q(9)) & biasInc_uid45_fpMulTest_q));
    expSumMBias_uid46_fpMulTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expSumMBias_uid46_fpMulTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expSumMBias_uid46_fpMulTest_o <= STD_LOGIC_VECTOR(SIGNED(expSumMBias_uid46_fpMulTest_a) - SIGNED(expSumMBias_uid46_fpMulTest_b));
        END IF;
    END PROCESS;
    expSumMBias_uid46_fpMulTest_q <= expSumMBias_uid46_fpMulTest_o(10 downto 0);

    -- expFracPreRound_uid66_fpMulTest(BITJOIN,65)@6
    expFracPreRound_uid66_fpMulTest_q <= expSumMBias_uid46_fpMulTest_q & fracRPostNorm_uid53_fpMulTest_q;

    -- expFracRPostRounding_uid69_fpMulTest(ADD,68)@6
    expFracRPostRounding_uid69_fpMulTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((44 downto 43 => expFracPreRound_uid66_fpMulTest_q(42)) & expFracPreRound_uid66_fpMulTest_q));
    expFracRPostRounding_uid69_fpMulTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("00000000000" & roundBitAndNormalizationOp_uid68_fpMulTest_q));
    expFracRPostRounding_uid69_fpMulTest_o <= STD_LOGIC_VECTOR(SIGNED(expFracRPostRounding_uid69_fpMulTest_a) + SIGNED(expFracRPostRounding_uid69_fpMulTest_b));
    expFracRPostRounding_uid69_fpMulTest_q <= expFracRPostRounding_uid69_fpMulTest_o(43 downto 0);

    -- expRPreExcExt_uid71_fpMulTest(BITSELECT,70)@6
    expRPreExcExt_uid71_fpMulTest_b <= STD_LOGIC_VECTOR(expFracRPostRounding_uid69_fpMulTest_q(43 downto 32));

    -- redist8_expRPreExcExt_uid71_fpMulTest_b_1(DELAY,136)
    redist8_expRPreExcExt_uid71_fpMulTest_b_1 : dspba_delay
    GENERIC MAP ( width => 12, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExcExt_uid71_fpMulTest_b, xout => redist8_expRPreExcExt_uid71_fpMulTest_b_1_q, clk => clk, aclr => areset );

    -- expRPreExc_uid72_fpMulTest(BITSELECT,71)@7
    expRPreExc_uid72_fpMulTest_in <= redist8_expRPreExcExt_uid71_fpMulTest_b_1_q(7 downto 0);
    expRPreExc_uid72_fpMulTest_b <= expRPreExc_uid72_fpMulTest_in(7 downto 0);

    -- redist7_expRPreExc_uid72_fpMulTest_b_1(DELAY,135)
    redist7_expRPreExc_uid72_fpMulTest_b_1 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expRPreExc_uid72_fpMulTest_b, xout => redist7_expRPreExc_uid72_fpMulTest_b_1_q, clk => clk, aclr => areset );

    -- expOvf_uid75_fpMulTest(COMPARE,74)@7
    expOvf_uid75_fpMulTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 12 => redist8_expRPreExcExt_uid71_fpMulTest_b_1_q(11)) & redist8_expRPreExcExt_uid71_fpMulTest_b_1_q));
    expOvf_uid75_fpMulTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000" & cstAllOWE_uid10_fpMulTest_q));
    expOvf_uid75_fpMulTest_o <= STD_LOGIC_VECTOR(SIGNED(expOvf_uid75_fpMulTest_a) - SIGNED(expOvf_uid75_fpMulTest_b));
    expOvf_uid75_fpMulTest_n(0) <= not (expOvf_uid75_fpMulTest_o(13));

    -- invExpXIsMax_uid35_fpMulTest(LOGICAL,34)@7
    invExpXIsMax_uid35_fpMulTest_q <= not (redist14_expXIsMax_uid30_fpMulTest_q_7_q);

    -- InvExpXIsZero_uid36_fpMulTest(LOGICAL,35)@7
    InvExpXIsZero_uid36_fpMulTest_q <= not (redist15_excZ_y_uid29_fpMulTest_q_7_q);

    -- excR_y_uid37_fpMulTest(LOGICAL,36)@7
    excR_y_uid37_fpMulTest_q <= InvExpXIsZero_uid36_fpMulTest_q and invExpXIsMax_uid35_fpMulTest_q;

    -- invExpXIsMax_uid21_fpMulTest(LOGICAL,20)@7
    invExpXIsMax_uid21_fpMulTest_q <= not (redist17_expXIsMax_uid16_fpMulTest_q_7_q);

    -- InvExpXIsZero_uid22_fpMulTest(LOGICAL,21)@7
    InvExpXIsZero_uid22_fpMulTest_q <= not (redist18_excZ_x_uid15_fpMulTest_q_7_q);

    -- excR_x_uid23_fpMulTest(LOGICAL,22)@7
    excR_x_uid23_fpMulTest_q <= InvExpXIsZero_uid22_fpMulTest_q and invExpXIsMax_uid21_fpMulTest_q;

    -- ExcROvfAndInReg_uid84_fpMulTest(LOGICAL,83)@7
    ExcROvfAndInReg_uid84_fpMulTest_q <= excR_x_uid23_fpMulTest_q and excR_y_uid37_fpMulTest_q and expOvf_uid75_fpMulTest_n;

    -- excYRAndExcXI_uid83_fpMulTest(LOGICAL,82)@7
    excYRAndExcXI_uid83_fpMulTest_q <= excR_y_uid37_fpMulTest_q and excI_x_uid19_fpMulTest_q;

    -- excXRAndExcYI_uid82_fpMulTest(LOGICAL,81)@7
    excXRAndExcYI_uid82_fpMulTest_q <= excR_x_uid23_fpMulTest_q and excI_y_uid33_fpMulTest_q;

    -- excXIAndExcYI_uid81_fpMulTest(LOGICAL,80)@7
    excXIAndExcYI_uid81_fpMulTest_q <= excI_x_uid19_fpMulTest_q and excI_y_uid33_fpMulTest_q;

    -- excRInf_uid85_fpMulTest(LOGICAL,84)@7 + 1
    excRInf_uid85_fpMulTest_qi <= excXIAndExcYI_uid81_fpMulTest_q or excXRAndExcYI_uid82_fpMulTest_q or excYRAndExcXI_uid83_fpMulTest_q or ExcROvfAndInReg_uid84_fpMulTest_q;
    excRInf_uid85_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRInf_uid85_fpMulTest_qi, xout => excRInf_uid85_fpMulTest_q, clk => clk, aclr => areset );

    -- expUdf_uid73_fpMulTest(COMPARE,72)@7
    expUdf_uid73_fpMulTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0000000000000" & GND_q));
    expUdf_uid73_fpMulTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((13 downto 12 => redist8_expRPreExcExt_uid71_fpMulTest_b_1_q(11)) & redist8_expRPreExcExt_uid71_fpMulTest_b_1_q));
    expUdf_uid73_fpMulTest_o <= STD_LOGIC_VECTOR(SIGNED(expUdf_uid73_fpMulTest_a) - SIGNED(expUdf_uid73_fpMulTest_b));
    expUdf_uid73_fpMulTest_n(0) <= not (expUdf_uid73_fpMulTest_o(13));

    -- excZC3_uid79_fpMulTest(LOGICAL,78)@7
    excZC3_uid79_fpMulTest_q <= excR_x_uid23_fpMulTest_q and excR_y_uid37_fpMulTest_q and expUdf_uid73_fpMulTest_n;

    -- excYZAndExcXR_uid78_fpMulTest(LOGICAL,77)@7
    excYZAndExcXR_uid78_fpMulTest_q <= redist15_excZ_y_uid29_fpMulTest_q_7_q and excR_x_uid23_fpMulTest_q;

    -- excXZAndExcYR_uid77_fpMulTest(LOGICAL,76)@7
    excXZAndExcYR_uid77_fpMulTest_q <= redist18_excZ_x_uid15_fpMulTest_q_7_q and excR_y_uid37_fpMulTest_q;

    -- excXZAndExcYZ_uid76_fpMulTest(LOGICAL,75)@7
    excXZAndExcYZ_uid76_fpMulTest_q <= redist18_excZ_x_uid15_fpMulTest_q_7_q and redist15_excZ_y_uid29_fpMulTest_q_7_q;

    -- excRZero_uid80_fpMulTest(LOGICAL,79)@7 + 1
    excRZero_uid80_fpMulTest_qi <= excXZAndExcYZ_uid76_fpMulTest_q or excXZAndExcYR_uid77_fpMulTest_q or excYZAndExcXR_uid78_fpMulTest_q or excZC3_uid79_fpMulTest_q;
    excRZero_uid80_fpMulTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excRZero_uid80_fpMulTest_qi, xout => excRZero_uid80_fpMulTest_q, clk => clk, aclr => areset );

    -- concExc_uid90_fpMulTest(BITJOIN,89)@8
    concExc_uid90_fpMulTest_q <= excRNaN_uid89_fpMulTest_q & excRInf_uid85_fpMulTest_q & excRZero_uid80_fpMulTest_q;

    -- excREnc_uid91_fpMulTest(LOOKUP,90)@8
    excREnc_uid91_fpMulTest_combproc: PROCESS (concExc_uid90_fpMulTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExc_uid90_fpMulTest_q) IS
            WHEN "000" => excREnc_uid91_fpMulTest_q <= "01";
            WHEN "001" => excREnc_uid91_fpMulTest_q <= "00";
            WHEN "010" => excREnc_uid91_fpMulTest_q <= "10";
            WHEN "011" => excREnc_uid91_fpMulTest_q <= "00";
            WHEN "100" => excREnc_uid91_fpMulTest_q <= "11";
            WHEN "101" => excREnc_uid91_fpMulTest_q <= "00";
            WHEN "110" => excREnc_uid91_fpMulTest_q <= "00";
            WHEN "111" => excREnc_uid91_fpMulTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREnc_uid91_fpMulTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExc_uid100_fpMulTest(MUX,99)@8
    expRPostExc_uid100_fpMulTest_s <= excREnc_uid91_fpMulTest_q;
    expRPostExc_uid100_fpMulTest_combproc: PROCESS (expRPostExc_uid100_fpMulTest_s, cstAllZWE_uid12_fpMulTest_q, redist7_expRPreExc_uid72_fpMulTest_b_1_q, cstAllOWE_uid10_fpMulTest_q)
    BEGIN
        CASE (expRPostExc_uid100_fpMulTest_s) IS
            WHEN "00" => expRPostExc_uid100_fpMulTest_q <= cstAllZWE_uid12_fpMulTest_q;
            WHEN "01" => expRPostExc_uid100_fpMulTest_q <= redist7_expRPreExc_uid72_fpMulTest_b_1_q;
            WHEN "10" => expRPostExc_uid100_fpMulTest_q <= cstAllOWE_uid10_fpMulTest_q;
            WHEN "11" => expRPostExc_uid100_fpMulTest_q <= cstAllOWE_uid10_fpMulTest_q;
            WHEN OTHERS => expRPostExc_uid100_fpMulTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid92_fpMulTest(CONSTANT,91)
    oneFracRPostExc2_uid92_fpMulTest_q <= "0000000000000000000000000000001";

    -- fracRPreExc_uid70_fpMulTest(BITSELECT,69)@6
    fracRPreExc_uid70_fpMulTest_in <= expFracRPostRounding_uid69_fpMulTest_q(31 downto 0);
    fracRPreExc_uid70_fpMulTest_b <= fracRPreExc_uid70_fpMulTest_in(31 downto 1);

    -- redist9_fracRPreExc_uid70_fpMulTest_b_2(DELAY,137)
    redist9_fracRPreExc_uid70_fpMulTest_b_2 : dspba_delay
    GENERIC MAP ( width => 31, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRPreExc_uid70_fpMulTest_b, xout => redist9_fracRPreExc_uid70_fpMulTest_b_2_q, clk => clk, aclr => areset );

    -- fracRPostExc_uid95_fpMulTest(MUX,94)@8
    fracRPostExc_uid95_fpMulTest_s <= excREnc_uid91_fpMulTest_q;
    fracRPostExc_uid95_fpMulTest_combproc: PROCESS (fracRPostExc_uid95_fpMulTest_s, cstZeroWF_uid11_fpMulTest_q, redist9_fracRPreExc_uid70_fpMulTest_b_2_q, oneFracRPostExc2_uid92_fpMulTest_q)
    BEGIN
        CASE (fracRPostExc_uid95_fpMulTest_s) IS
            WHEN "00" => fracRPostExc_uid95_fpMulTest_q <= cstZeroWF_uid11_fpMulTest_q;
            WHEN "01" => fracRPostExc_uid95_fpMulTest_q <= redist9_fracRPreExc_uid70_fpMulTest_b_2_q;
            WHEN "10" => fracRPostExc_uid95_fpMulTest_q <= cstZeroWF_uid11_fpMulTest_q;
            WHEN "11" => fracRPostExc_uid95_fpMulTest_q <= oneFracRPostExc2_uid92_fpMulTest_q;
            WHEN OTHERS => fracRPostExc_uid95_fpMulTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- R_uid103_fpMulTest(BITJOIN,102)@8
    R_uid103_fpMulTest_q <= signRPostExc_uid102_fpMulTest_q & expRPostExc_uid100_fpMulTest_q & fracRPostExc_uid95_fpMulTest_q;

    -- xOut(GPOUT,4)@8
    q <= R_uid103_fpMulTest_q;

END normal;
