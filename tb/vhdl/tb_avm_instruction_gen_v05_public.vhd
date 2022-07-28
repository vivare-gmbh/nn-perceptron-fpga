-- COPYRIGHT (C) 2022 by Jens Gutschmidt / VIVARE GmbH Switzerland
-- (email: opencores@vivare-services.com)
-- 
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or any
-- later version.
-- 
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
-- 
-- **************************************
--
-- File: tb_avm_instruction_gen_v05.vhd
-- 
-- Version: 5.0
-- Date: 22.Jul.2022
-- Author: Jens Gutschmidt / opencores@vivare-services.com
-- Cause: Wrong value for Threshold (0x25 -> 0x20)
--        Will not cover the values described in specification
--        Appendix B. Initiate a new specification's version.
-- 
-- Version: 4.0
-- Date: 20.Jul.2022
-- Author: Jens Gutschmidt / opencores@vivare-services.com
-- Cause: Adoptions for public
-- 
-- THIS TEST BENCH IS ONLY FOR INFORMATION.
-- IT CONTAINS TESTS FOR SYMANTIC EXPERIMENTS AND OTHER NON-PROJECT
-- RELATED STUFF.
-- USE IT ON OWN RISC !!!
-- **************************************

USE std.textio.all;

LIBRARY work;
USE work.memory_vhd_v03_pkg.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_textio.all;

LIBRARY modelsim_lib;
USE modelsim_lib.transactions.all;

ENTITY tb_avm_instruction_gen_v05_public IS
END ENTITY tb_avm_instruction_gen_v05_public;

--
ARCHITECTURE testbench OF tb_avm_instruction_gen_v05_public IS

   -- Component Declarations
   COMPONENT p0300_m00000_s_v03_top_level_blk
   PORT (
      wb_clk_i    : IN     std_logic ;
      wb_rst_i    : IN     std_logic ;
      wb_adr_i    : IN     WB_ADDR_WIDTH_T ;
      wb_dat_i    : IN     WB_DATA_WIDTH_T ;
      wb_stb_i    : IN     std_logic ;
      wb_cyc_i    : IN     std_logic ;
      wb_we_i     : IN     std_logic ;

      wb_ack_o    : OUT    std_logic ;
      wb_dat_o    : OUT    WB_DATA_WIDTH_T
   );
   END COMPONENT;
   
   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : p0300_m00000_s_v03_top_level_blk USE ENTITY work.p0300_m00000_s_v03_top_level_blk;
   -- pragma synthesis_on


   signal clk_gen_o      : std_ulogic := '0';
   signal rst_proc_o     : std_ulogic := '0';
--   signal res_proc_o_i   : std_ulogic := '0';
   signal rst_run_proc_o : std_logic;

   -- WN internal signals
   signal tb_wb_adri_oi  : WB_ADDR_WIDTH_T ;
   signal tb_wb_adro_oi  : WB_ADDR_WIDTH_T := (others => '0') ;
--   signal tb_wb_adro_oi  : WB_ADDR_WIDTH_T ;
   signal tb_wb_dout_oi  : WB_DATA_WIDTH_T ;
   signal tb_wb_stb_oi   : std_logic := '0' ;
   signal tb_wb_cyc_oi   : std_logic := '0' ;
   signal tb_wb_we_oi    : std_logic := '0' ;

   signal tb_wb_ack_oi   : std_logic ;
   signal tb_wb_din_oi   : WB_DATA_WIDTH_T ;
   signal tb_wb_clear_epoch_oi   : WB_DATA_WIDTH_T ;
   signal tb_wb_thres_oi   : WB_DATA_WIDTH_T ;
   -- ////////////////////////////////////////////////////////
   
   signal done           : boolean   := FALSE;

   constant PERIOD       : Time := 20 ns;
   constant PD           : Time := 0 ns;

   constant PLUS_ONE     : integer := 1;
   constant MINUS_ONE    : integer := -1;

BEGIN
    tb_avm_test: process
    variable count_pattern     : integer;
    variable count_loop        : integer;
    variable count_data        : integer;

    variable hStream02         : TrStream := create_transaction_stream("stream02", "transaction");
    variable hStream01         : TrStream := create_transaction_stream("stream01", "transaction2");
    
    variable hTrans01          : TrTransaction := 0;
    variable hTrans02          : TrTransaction := 0;
    variable hTrans03          : TrTransaction := 0;
    variable hTrans04          : TrTransaction := 0;
    
    variable loop_finished     : boolean   := FALSE;
    variable loop_finished_a   : boolean   := FALSE;
    variable wb_adr_oi         : WB_ADDR_WIDTH_T ;
    
    variable mem_matrix_i_len  : integer   := 6;
    variable mem_matrix_j_len  : integer   := 3;
    type tb_s_mem_t is array ( 0 to ( mem_matrix_i_len - 1 ) ) of integer; -- 
    type tb_t_mem_t is array ( 0 to ( mem_matrix_j_len - 1 ) ) of integer; --
    type tb_w_mem_t is array ( 0 to ( mem_matrix_i_len * mem_matrix_j_len ) - 1 ) of integer; -- matrix 3 x 2

    variable tb_s_mem            : tb_s_mem_t;
    variable tb_t_mem            : tb_t_mem_t;
    variable tb_w_mem            : tb_w_mem_t;

    file outfile : text is out "outimgvhdl.txt";
    file outfile_w : text is out "w_memory_up_down.txt";
    file outfile_bias : text is out "bias_memory_up_down.txt";
    file outfile_test : text is out "test.txt";
    file outfile_answer : text is out "answer.txt";
    variable buff_out : line; --line number declaration
    variable buff_out_answer : line; --line number declaration
    variable component_lv : std_logic_vector ( mem_matrix_i_len - 1 downto 0 );


-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ///////////////////////////////////  WB READ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    procedure wb_read_proc_bfm
    (
      signal   clk_i     : IN     std_logic ;
      signal   wb_ack_i  : IN     std_logic ;
      constant wb_adr_i  : IN     WB_ADDR_WIDTH_T ;
      constant wb_dat_o  : IN     WB_DATA_WIDTH_T ;

      signal   wb_adr_o  : OUT    WB_ADDR_WIDTH_T ;
      signal   wb_stb_o  : OUT    std_logic ;
      signal   wb_cyc_o  : OUT    std_logic ;
      signal   wb_we_o   : OUT    std_logic
    ) is
    begin
        hTrans02 := begin_transaction(hStream02, "WB-READ");
        add_color(hTrans02, "green yellow");
        add_attribute(hTrans02, wb_adr_i, "wb_adr");

        wb_adr_o    <= wb_adr_i  after PD;
        wb_we_o     <= '0'  after PD;
        wb_stb_o    <= '1'  after PD;
        wb_cyc_o    <= '1'  after PD;
        wait until clk_i'event and clk_i = '1' and wb_ack_i = '1';
--        wb_stb_o    <= '0'  after PD;
--        wb_cyc_o    <= '0'  after PD;
        wb_stb_o    <= '0';
        wb_cyc_o    <= '0';
--        wait until clk_i'event and clk_i = '1';
        add_attribute(hTrans02, wb_dat_o, "wb_dat_o");
--        wait until clk_i'event and clk_i = '1';

        end_transaction(hTrans02);
        free_transaction(hTrans02);
    end wb_read_proc_bfm;
-- *********************************************************************************

-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- /////////////////////////////////// WB WRITE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    procedure wb_write_proc_bfm
    (
      signal   clk_i     : IN     std_logic ;
      signal   wb_ack_i  : IN     std_logic ;
      constant wb_adr_i  : IN     WB_ADDR_WIDTH_T ;
      constant wb_dat_i  : IN     WB_DATA_WIDTH_T ;

      signal   wb_adr_o  : OUT    WB_ADDR_WIDTH_T ;
      signal   wb_dat_o  : OUT    WB_DATA_WIDTH_T ;
      signal   wb_stb_o  : OUT    std_logic ;
      signal   wb_cyc_o  : OUT    std_logic ;
      signal   wb_we_o   : OUT    std_logic
    ) is
    begin
        hTrans02 := begin_transaction(hStream02, "WB-WRITE");
        add_color(hTrans02, "thistle");
        add_attribute(hTrans02, wb_adr_i, "wb_adr");
        add_attribute(hTrans02, wb_dat_i, "wb_dat_i");

        wb_adr_o    <= wb_adr_i  after PD;
        wb_dat_o    <= wb_dat_i  after PD;
        wb_we_o     <= '1'  after PD;
        wb_stb_o    <= '1'  after PD;
        wb_cyc_o    <= '1'  after PD;
        wait until clk_i'event and clk_i = '1' and wb_ack_i = '1';
--        wb_we_o     <= '0'  after PD;
--        wb_stb_o    <= '0'  after PD;
--        wb_cyc_o    <= '0'  after PD;
        wb_we_o     <= '0';
        wb_stb_o    <= '0';
        wb_cyc_o    <= '0';
--        wait until clk_i'event and clk_i = '1';
--        wait until clk_i'event and clk_i = '1';

        end_transaction(hTrans02);
        free_transaction(hTrans02);
    end wb_write_proc_bfm;
-- *********************************************************************************

-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ////////////////////////////////  WB READ READY \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ////////////////////////////////////////*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    procedure wb_read_ready_proc_bfm
    (
      signal   clk_i     : IN     std_logic ;
      signal   wb_ack_i  : IN     std_logic ;
      constant wb_adr_i  : IN     WB_ADDR_WIDTH_T ;
      constant wb_dat_o  : IN     WB_DATA_WIDTH_T ;

      signal   wb_adr_o  : OUT    WB_ADDR_WIDTH_T ;
      signal   wb_stb_o  : OUT    std_logic ;
      signal   wb_cyc_o  : OUT    std_logic ;
      signal   wb_we_o   : OUT    std_logic
    ) is
    begin

        hTrans02 := begin_transaction(hStream02, "WB-READ-READY");
        add_color(hTrans02, "yellow");
        add_attribute(hTrans02, wb_adr_i, "wb_adr");

        wb_adr_o    <= wb_adr_i  after PD;
        wb_we_o     <= '0'  after PD;
        wb_stb_o    <= '1'  after PD;
        wb_cyc_o    <= '1'  after PD;
        wait until clk_i'event and clk_i = '1' and wb_ack_i = '1';
--        wb_stb_o    <= '0'  after PD;
--        wb_cyc_o    <= '0'  after PD;
        wb_stb_o    <= '0';
        wb_cyc_o    <= '0';
--        wait until clk_i'event and clk_i = '1';
        add_attribute(hTrans02, wb_dat_o, "wb_dat_o");
--        wait until clk_i'event and clk_i = '1';

        end_transaction(hTrans02);
        free_transaction(hTrans02);
    end wb_read_ready_proc_bfm;
-- *********************************************************************************

    begin
      count_loop    := 0 ;
      tb_wb_adri_oi <= (others => '0') ;
      tb_wb_din_oi <= (others => '0') ;
      tb_wb_thres_oi <= X"00000020" ;

      hTrans01 := begin_transaction(hStream01, "RESET");
      add_color(hTrans01, "blue");

      wait until clk_gen_o'event and clk_gen_o = '0';
      rst_proc_o <= '1' after PD;
      wait until clk_gen_o'event and clk_gen_o = '1';
      wait until clk_gen_o'event and clk_gen_o = '1';
      wait until clk_gen_o'event and clk_gen_o = '1';   -- delay for 3 clks to init.
      rst_proc_o <= '0' after PD;

      end_transaction(hTrans01);
      free_transaction(hTrans01);

--    *************************************************************************

      hTrans01 := begin_transaction ( hStream01, "First_WB_Test" );
      add_color ( hTrans01, "green" );

      wb_read_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
        tb_wb_dout_oi ,
        tb_wb_adro_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      READ All Latency Register, tb_wb_adri_oi <= "01110", d14, 0x0E
      wb_read_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_ALLLAT, WB_ADDR_WIDTH ) ) ,
        tb_wb_dout_oi ,
        tb_wb_adro_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      WRITE Threshold Register, tb_wb_adri_oi <= "00001", d01, 0x01
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_THRES, WB_ADDR_WIDTH ) ) ,
        tb_wb_thres_oi ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      READ Threshold Register, tb_wb_adri_oi <= "00001", d01, 0x01
      wb_read_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_THRES, WB_ADDR_WIDTH ) ) ,
        tb_wb_dout_oi ,
        tb_wb_adro_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      WRITE Bias Register
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_BIAS, WB_ADDR_WIDTH ) ) ,
        X"00000001" ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      READ Bias Register
      wb_read_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_BIAS, WB_ADDR_WIDTH ) ) ,
        tb_wb_dout_oi ,
        tb_wb_adro_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

      end_transaction(hTrans01);
      free_transaction(hTrans01);

      hTrans01 := begin_transaction ( hStream01, "Wait_for_core_is_ready" );
      add_color ( hTrans01, "yellow" );

--      READ Status Register, tb_wb_adri_oi <= "00000"
        wb_read_ready_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STARTI, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "Start_Stop_values" );
      add_color ( hTrans01, "cyan" );

--      WRITE STARTI Register, tb_wb_adri_oi <= "00111"
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STARTI, WB_ADDR_WIDTH ) ) ,
        X"00000000" ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      WRITE STARTJ Register, tb_wb_adri_oi <= "01001"
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STARTJ, WB_ADDR_WIDTH ) ) ,
        X"00000000" ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      WRITE STOPI Register, tb_wb_adri_oi <= "01000"
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STOPI, WB_ADDR_WIDTH ) ) ,
        std_logic_vector ( conv_unsigned ( mem_matrix_i_len-1, WB_DATA_WIDTH ) ) ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

--      WRITE STOPJ Register, tb_wb_adri_oi <= "01010"
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STOPJ, WB_ADDR_WIDTH ) ) ,
        std_logic_vector ( conv_unsigned ( mem_matrix_j_len-1, WB_DATA_WIDTH ) ) ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "Wait_for_READY" );
      add_color ( hTrans01, "white" );

      wb_adr_oi   := "00000";
      loop_finished := FALSE;
      while ( NOT loop_finished ) loop

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          wb_adr_oi ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        if ( (tb_wb_dout_oi (STAT_RDY) = '1') ) then
          loop_finished := TRUE;
        end if;

      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );


      hTrans01 := begin_transaction ( hStream01, "WRITE-W-Memory_until_end" );
      add_color ( hTrans01, "orange" );

--      READ W-MEM, tb_wb_adri_oi <= "10011"
      count_data := 0;
      count_loop := 0;
      loop_finished_a := FALSE;

      while ( NOT loop_finished_a ) loop

        tb_w_mem (count_loop) := count_data;

--      WRITE W-MEM
        wb_write_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_START5_W, WB_ADDR_WIDTH ) ) ,
          std_logic_vector ( conv_unsigned ( count_data, WB_DATA_WIDTH ) ) ,
          tb_wb_adro_oi ,
          tb_wb_din_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );
        
        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        count_data := count_data + 1 ;
        count_loop := count_loop + 1 ;
        if ( (tb_wb_dout_oi (STAT_RD_WR_COMPLETE) = '1') ) then
          loop_finished_a := TRUE;
        end if;

      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "READ-W-Memory_until_end" );
      add_color ( hTrans01, "yellow" );

--      READ W-MEM, tb_wb_adri_oi <= "10011"
      count_loop := 0;
      loop_finished_a := FALSE;
      while ( NOT loop_finished_a ) loop

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_START5_W, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        if ( NOT (tb_wb_dout_oi = std_logic_vector ( conv_unsigned ( tb_w_mem (count_loop), WB_DATA_WIDTH ) )) ) then
          loop_finished_a := TRUE;
          hTrans04 := begin_transaction ( hStream02, "READ-W-Memory_MISMATCH" );
          add_color ( hTrans04, "red" );
          add_attribute ( hTrans04, tb_wb_dout_oi, "exp_tb_wb_dout_oi" );
          add_attribute ( hTrans04, std_logic_vector ( conv_unsigned ( tb_w_mem (count_loop), WB_DATA_WIDTH ) ), "rd_tb_wb_dout_oi" );

          wait for 100ns;
          end_transaction ( hTrans04 );
          free_transaction ( hTrans04 );
          
        end if;

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        count_loop := count_loop + 1 ;
        if ( (tb_wb_dout_oi ( STAT_RD_WR_COMPLETE) = '1' ) ) then
          loop_finished_a := TRUE;
        end if;

      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "Start_INIT_Process" );
      add_color ( hTrans01, "medium sea green" );

      loop_finished_a := FALSE;

--      INIT
        wb_write_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_START3, WB_ADDR_WIDTH ) ) ,
          X"00000000" ,
          tb_wb_adro_oi ,
          tb_wb_din_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );
        
      while ( NOT loop_finished_a ) loop

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        if ( (tb_wb_dout_oi ( STAT_RDY) = '1' ) ) then
          loop_finished_a := TRUE;
        end if;

      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "Enable_Interrupt" );
      add_color ( hTrans01, "Magenta" );

--      Enable Interrupt, tb_wb_adri_oi <= "00000"
      wb_write_proc_bfm
      (
        clk_gen_o ,
        tb_wb_ack_oi ,
        std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
        X"00000008" ,
        tb_wb_adro_oi ,
        tb_wb_din_oi ,
        tb_wb_stb_oi ,
        tb_wb_cyc_oi ,
        tb_wb_we_oi
      );

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

 
      hTrans01 := begin_transaction ( hStream01, "Training" );
      add_color ( hTrans01, "violett" );
      tb_wb_clear_epoch_oi <= (others => '1') ;

      for count_pattern in 0 to 63 loop
        component_lv := std_logic_vector ( conv_signed ( count_pattern, mem_matrix_i_len ) );
        write ( buff_out, string'("-- Pattern Number: ") );
        write ( buff_out, count_pattern );
        write ( buff_out, string'("  ") );
        write ( buff_out, component_lv );
  
        tb_s_mem (0) := MINUS_ONE;
        tb_s_mem (1) := MINUS_ONE;
        tb_s_mem (2) := MINUS_ONE;
        tb_s_mem (3) := MINUS_ONE;
        tb_s_mem (4) := MINUS_ONE;
        tb_s_mem (5) := MINUS_ONE;
  
        if ( ( component_lv (0) = '1' ) ) then
          tb_s_mem (0) := PLUS_ONE;
        end if;
        if ( ( component_lv (1) = '1' ) ) then
          tb_s_mem (1) := PLUS_ONE;
        end if;
        if ( ( component_lv (2) = '1' ) ) then
          tb_s_mem (2) := PLUS_ONE;
        end if;
        if ( ( component_lv (3) = '1' ) ) then
          tb_s_mem (3) := PLUS_ONE;
        end if;
        if ( ( component_lv (4) = '1' ) ) then
          tb_s_mem (4) := PLUS_ONE;
        end if;
        if ( ( component_lv (5) = '1' ) ) then
          tb_s_mem (5) := PLUS_ONE;
        end if;
  
        tb_t_mem (0) := MINUS_ONE;  -- UP
        tb_t_mem (1) := MINUS_ONE; -- DOWN
        tb_t_mem (2) := MINUS_ONE; -- STOP
  
        if ( (component_lv = "010101" ) ) then
          tb_t_mem (0) := PLUS_ONE;  -- UP
          tb_t_mem (1) := MINUS_ONE; -- DOWN
          tb_t_mem (2) := MINUS_ONE; -- STOP
          write ( buff_out, string'("      UP") );
        end if;
        if ( (component_lv = "101010" ) ) then
          tb_t_mem (0) := MINUS_ONE;  -- UP
          tb_t_mem (1) := PLUS_ONE; -- DOWN
          tb_t_mem (2) := MINUS_ONE; -- STOP
          write ( buff_out, string'("      DOWN") );
        end if;
        if ( (component_lv = "111011" ) ) then
          tb_t_mem (0) := MINUS_ONE;  -- UP
          tb_t_mem (1) := MINUS_ONE; -- DOWN
          tb_t_mem (2) := PLUS_ONE; -- STOP
          write ( buff_out, string'("      STOP") );
        end if;
  
        writeline ( outfile, buff_out );
        write ( buff_out, string'("-- Components") );
        writeline ( outfile, buff_out );
  
        hTrans04 := begin_transaction ( hStream02, "WRITE-S-Memory" );
        add_color ( hTrans04, "light blue" );
  
        count_data := 0;
        count_loop := 0;
        loop_finished_a := FALSE;
        while ( NOT loop_finished_a ) loop
  
  --      WRITE S-MEM
          wb_write_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START5_S, WB_ADDR_WIDTH ) ) ,
            std_logic_vector ( conv_signed ( tb_s_mem (count_loop), WB_DATA_WIDTH ) ) ,
            tb_wb_adro_oi ,
            tb_wb_din_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
          write ( buff_out, std_logic_vector ( conv_signed ( tb_s_mem (count_loop), WB_DATA_WIDTH ) ) );
          writeline ( outfile, buff_out );
  
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_data := count_data + 1 ;
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi (STAT_RD_WR_COMPLETE) = '1') ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );
  
        hTrans04 := begin_transaction ( hStream02, "WRITE-T-Memory" );
        add_color ( hTrans04, "light yellow" );
        write ( buff_out, string'("-- Answer") );
        writeline ( outfile, buff_out );
  
        count_data := 0;
        count_loop := 0;
        loop_finished_a := FALSE;
        while ( NOT loop_finished_a ) loop
  
  --      WRITE T-MEM
          wb_write_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START5_T, WB_ADDR_WIDTH ) ) ,
            std_logic_vector ( conv_signed ( tb_t_mem (count_loop), WB_DATA_WIDTH ) ) ,
            tb_wb_adro_oi ,
            tb_wb_din_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
          write ( buff_out, std_logic_vector ( conv_signed ( tb_t_mem (count_loop), WB_DATA_WIDTH ) ) );
          writeline ( outfile, buff_out );
          
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_data := count_data + 1 ;
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi (STAT_RD_WR_COMPLETE) = '1') ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );
  
        hTrans04 := begin_transaction ( hStream02, "Start_Training_Process" );
        add_color ( hTrans04, "light blue" );
  
        loop_finished_a := FALSE;
  
  --      Training
          wb_write_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START6, WB_ADDR_WIDTH ) ) ,
            tb_wb_clear_epoch_oi ,
            tb_wb_adro_oi ,
            tb_wb_din_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
        tb_wb_clear_epoch_oi <= (others => '0') ;
          
        while ( NOT loop_finished_a ) loop
  
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi ( STAT_INT_TRAIN) = '1' ) ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );
      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "READ-W-Memory_to_file" );
      add_color ( hTrans01, "violet red" );
      write ( buff_out, string'("-- W-Memory content for UP/DOWN/STOP pattern") );
      writeline ( outfile_w, buff_out );

--      READ W-MEM, tb_wb_adri_oi <= "10011"
      count_loop := 0;
      loop_finished_a := FALSE;
      while ( NOT loop_finished_a ) loop

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_START5_W, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        write ( buff_out, tb_wb_dout_oi );
        writeline ( outfile_w, buff_out );
        
        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        count_loop := count_loop + 1 ;
        if ( (tb_wb_dout_oi ( STAT_RD_WR_COMPLETE) = '1' ) ) then
          loop_finished_a := TRUE;
        end if;
      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "READ-BIAS-Memory_to_file" );
      add_color ( hTrans01, "violet red" );
      write ( buff_out, string'("-- BIAS-Memory content for UP/DOWN/STOP pattern") );
      writeline ( outfile_bias, buff_out );

      count_loop := 0;
      loop_finished_a := FALSE;
      while ( NOT loop_finished_a ) loop

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_START5_BIAS, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        write ( buff_out, tb_wb_dout_oi );
        writeline ( outfile_bias, buff_out );

        wb_read_proc_bfm
        (
          clk_gen_o ,
          tb_wb_ack_oi ,
          std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
          tb_wb_dout_oi ,
          tb_wb_adro_oi ,
          tb_wb_stb_oi ,
          tb_wb_cyc_oi ,
          tb_wb_we_oi
        );

        count_loop := count_loop + 1 ;
        if ( (tb_wb_dout_oi ( STAT_RD_WR_COMPLETE) = '1' ) ) then
          loop_finished_a := TRUE;
        end if;
      end loop;

      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );

      hTrans01 := begin_transaction ( hStream01, "Test" );
      add_color ( hTrans01, "maroon" );

      for count_pattern in 0 to 63 loop
        component_lv := std_logic_vector ( conv_signed ( count_pattern, mem_matrix_i_len ) );
        write ( buff_out, string'("-- Pattern Number: ") );
        write ( buff_out, count_pattern );
        writeline ( outfile_test, buff_out );
        
        tb_s_mem (0) := MINUS_ONE;
        tb_s_mem (1) := MINUS_ONE;
        tb_s_mem (2) := MINUS_ONE;
        tb_s_mem (3) := MINUS_ONE;
        tb_s_mem (4) := MINUS_ONE;
        tb_s_mem (5) := MINUS_ONE;
  
        if ( ( component_lv (0) = '1' ) ) then
          tb_s_mem (0) := PLUS_ONE;
        end if;
        if ( ( component_lv (1) = '1' ) ) then
          tb_s_mem (1) := PLUS_ONE;
        end if;
        if ( ( component_lv (2) = '1' ) ) then
          tb_s_mem (2) := PLUS_ONE;
        end if;
        if ( ( component_lv (3) = '1' ) ) then
          tb_s_mem (3) := PLUS_ONE;
        end if;
        if ( ( component_lv (4) = '1' ) ) then
          tb_s_mem (4) := PLUS_ONE;
        end if;
        if ( ( component_lv (5) = '1' ) ) then
          tb_s_mem (5) := PLUS_ONE;
        end if;
  
        write ( buff_out, string'("-- Components") );
        writeline ( outfile_test, buff_out );
  
        hTrans04 := begin_transaction ( hStream02, "WRITE-S-Memory" );
        add_color ( hTrans04, "light blue" );
  
        count_data := 0;
        count_loop := 0;
        loop_finished_a := FALSE;
        
        while ( NOT loop_finished_a ) loop
  
  --      WRITE S-MEM
          wb_write_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START5_S, WB_ADDR_WIDTH ) ) ,
            std_logic_vector ( conv_signed ( tb_s_mem (count_loop), WB_DATA_WIDTH ) ) ,
            tb_wb_adro_oi ,
            tb_wb_din_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
          write ( buff_out, std_logic_vector ( conv_signed ( tb_s_mem (count_loop), WB_DATA_WIDTH ) ) );
          writeline ( outfile_test, buff_out );
  
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_data := count_data + 1 ;
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi (STAT_RD_WR_COMPLETE) = '1') ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );
  

        hTrans04 := begin_transaction ( hStream02, "Start_Test_Process" );
        add_color ( hTrans04, "light blue" );
  
        loop_finished_a := FALSE;
  
  --      Training
          wb_write_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START4, WB_ADDR_WIDTH ) ) ,
            X"00000000" ,
            tb_wb_adro_oi ,
            tb_wb_din_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
          
        while ( NOT loop_finished_a ) loop
  
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi ( STAT_INT_TEST) = '1' ) ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );

        hTrans04 := begin_transaction ( hStream02, "READ-T-Memory" );
        add_color ( hTrans04, "sate blue" );
        write ( buff_out, string'("-- Answer") );
        writeline ( outfile_test, buff_out );
  
        count_data := 0;
        count_loop := 0;
        loop_finished_a := FALSE;
        write ( buff_out_answer, count_pattern );

        while ( NOT loop_finished_a ) loop
  
  --      READ T-MEM
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_START5_T, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
            write ( buff_out, tb_wb_dout_oi );
            write ( buff_out, string'("  ") );
    
            write ( buff_out_answer, string'(",") );
            if ( signed ( tb_wb_dout_oi ) < 0 ) then
              hwrite ( buff_out_answer, std_logic_vector ( conv_unsigned ( (unsigned ( not std_logic_vector (tb_wb_dout_oi) ) + 1), WB_DATA_WIDTH )) );
              write ( buff_out_answer, string'(",-1") );
            else
              hwrite ( buff_out_answer, (  ( tb_wb_dout_oi ) ) );
              write ( buff_out_answer, string'(",1") );
            end if;
  
          wb_read_proc_bfm
          (
            clk_gen_o ,
            tb_wb_ack_oi ,
            std_logic_vector ( conv_unsigned ( WB_STAT_A, WB_ADDR_WIDTH ) ) ,
            tb_wb_dout_oi ,
            tb_wb_adro_oi ,
            tb_wb_stb_oi ,
            tb_wb_cyc_oi ,
            tb_wb_we_oi
          );
  
          count_loop := count_loop + 1 ;
          if ( (tb_wb_dout_oi ( STAT_RD_WR_COMPLETE ) = '1' ) ) then
            loop_finished_a := TRUE;
          end if;
        end loop;
        writeline ( outfile_test, buff_out );
        writeline ( outfile_answer, buff_out_answer );
  
        end_transaction ( hTrans04 );
        free_transaction ( hTrans04 );
      end loop;
      end_transaction ( hTrans01 );
      free_transaction ( hTrans01 );


      done <= TRUE;
   end process tb_avm_test;

   clk_gen : process
   begin
       while (not done) loop
           clk_gen_o <= '0','1' after PERIOD/2;
           wait for PERIOD;
       end loop;
       wait;
   end process clk_gen;
   
-- Instance port mappings.
U_0 : p0300_m00000_s_v03_top_level_blk
   PORT MAP (
     wb_clk_i    => clk_gen_o ,
     wb_rst_i    => rst_proc_o ,
     wb_adr_i    => tb_wb_adro_oi ,
     wb_dat_i    => tb_wb_din_oi ,
     wb_stb_i    => tb_wb_stb_oi ,
     wb_cyc_i    => tb_wb_cyc_oi ,
     wb_we_i     => tb_wb_we_oi ,

     wb_ack_o    => tb_wb_ack_oi ,
     wb_dat_o    => tb_wb_dout_oi
   );

END ARCHITECTURE testbench;

