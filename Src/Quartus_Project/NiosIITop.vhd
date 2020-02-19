--*****************************************************************************************
-- Project:     TimeSync
--
-- Author:      Sven Meier, NetTimeLogic GmbH
--
-- License:     Copyright (c) 2017, NetTimeLogic GmbH, Switzerland, Sven Meier <contact@nettimelogic.com>
--              All rights reserved.
--                
--              THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--              ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--              WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--              DISCLAIMED. IN NO EVENT SHALL NetTimeLogic GmbH BE LIABLE FOR ANY
--              DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--              (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--              LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--              ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--              (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--              SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--*****************************************************************************************


--*****************************************************************************************
-- General Libraries
--*****************************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--*****************************************************************************************
-- Specific Libraries
--*****************************************************************************************


--*****************************************************************************************
-- Entity Declaration
--*****************************************************************************************
entity NiosIITop is
    port (
        -- System            
        Mhz25Clk_ClkIn                  : in    std_logic;
        RstN_RstIn                      : in    std_logic;

        -- General
        Led_DatOut                      : out   std_logic_vector(7 downto 0);

        -- Uart Input
        Uart_DatIn                      : in    std_logic;
        -- Uart Output
        Uart_DatOut                     : out   std_logic;
        
        -- SDRAM
        sdram_0_addr                    : out   std_logic_vector(11 downto 0);
        sdram_0_ba                      : out   std_logic_vector(1 downto 0);
        sdram_0_cas_n                   : out   std_logic;
        sdram_0_cke                     : out   std_logic;
        sdram_0_cs_n                    : out   std_logic;
        sdram_0_ras_n                   : out   std_logic;
        sdram_0_we_n                    : out   std_logic;
        sdram_0_dq                      : inout std_logic_vector(15 downto 0);
        sdram_0_dqm                     : out   std_logic_vector(1 downto 0);
        sdram_clk                       : out   std_logic;

        eth1_rst                        : out   std_logic;

        -- Ethernet 0
        eth0_mdio                       : inout std_logic;
        eth0_mdc                        : out   std_logic;
        eth0_rst                        : out   std_logic;
                                        
        eth0_rxc                        : in    std_logic;
        eth0_txc                        : in    std_logic;
                                        
        eth0_rxd                        : in    std_logic_vector(3 downto 0);
        eth0_rxer                       : in    std_logic;
        eth0_rxdv                       : in    std_logic;
                                        
        eth0_txd                        : out   std_logic_vector(3 downto 0);
        eth0_txen                       : out   std_logic;
                                        
        eth0_crs                        : in    std_logic;
        eth0_col                        : in    std_logic
     );
end entity NiosIITop;

--*****************************************************************************************
-- Architecture Declaration
--*****************************************************************************************
architecture NiosIITop_Arch of NiosIITop is
    --*************************************************************************************
    -- Component Definitions
    --*************************************************************************************
    component Nios is
    port (
        altpll_0_c1_clk                           : out   std_logic;                                        -- clk
        clk_clk                                   : in    std_logic                     := 'X';             -- clk
        reset_reset_n                             : in    std_logic                     := 'X';             -- reset_n
        sdram_controller_0_addr                   : out   std_logic_vector(11 downto 0);                    -- addr
        sdram_controller_0_ba                     : out   std_logic_vector(1 downto 0);                     -- ba
        sdram_controller_0_cas_n                  : out   std_logic;                                        -- cas_n
        sdram_controller_0_cke                    : out   std_logic;                                        -- cke
        sdram_controller_0_cs_n                   : out   std_logic;                                        -- cs_n
        sdram_controller_0_dq                     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
        sdram_controller_0_dqm                    : out   std_logic_vector(1 downto 0);                     -- dqm
        sdram_controller_0_ras_n                  : out   std_logic;                                        -- ras_n
        sdram_controller_0_we_n                   : out   std_logic;                                        -- we_n
        uart_0_rxd                                : in    std_logic                     := 'X';             -- rxd
        uart_0_txd                                : out   std_logic;                                        -- txd
        tse_mac_pcs_mac_tx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
        tse_mac_pcs_mac_rx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
        tse_mac_mac_status_connection_set_10      : in    std_logic                     := 'X';             -- set_10
        tse_mac_mac_status_connection_set_1000    : in    std_logic                     := 'X';             -- set_1000
        tse_mac_mac_status_connection_eth_mode    : out   std_logic;                                        -- eth_mode
        tse_mac_mac_status_connection_ena_10      : out   std_logic;                                        -- ena_10
        tse_mac_mac_mii_connection_mii_rx_d       : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- mii_rx_d
        tse_mac_mac_mii_connection_mii_rx_dv      : in    std_logic                     := 'X';             -- mii_rx_dv
        tse_mac_mac_mii_connection_mii_rx_err     : in    std_logic                     := 'X';             -- mii_rx_err
        tse_mac_mac_mii_connection_mii_tx_d       : out   std_logic_vector(3 downto 0);                     -- mii_tx_d
        tse_mac_mac_mii_connection_mii_tx_en      : out   std_logic;                                        -- mii_tx_en
        tse_mac_mac_mii_connection_mii_tx_err     : out   std_logic;                                        -- mii_tx_err
        tse_mac_mac_mii_connection_mii_crs        : in    std_logic                     := 'X';             -- mii_crs
        tse_mac_mac_mii_connection_mii_col        : in    std_logic                     := 'X';             -- mii_col
        tse_mac_mac_mdio_connection_mdc           : out   std_logic;                                        -- mdc
        tse_mac_mac_mdio_connection_mdio_in       : in    std_logic                     := 'X';             -- mdio_in
        tse_mac_mac_mdio_connection_mdio_out      : out   std_logic;                                        -- mdio_out
        tse_mac_mac_mdio_connection_mdio_oen      : out   std_logic;                                        -- mdio_oen
        tse_mac_mac_misc_connection_ff_tx_crc_fwd : in    std_logic                     := 'X';             -- ff_tx_crc_fwd
        tse_mac_mac_misc_connection_ff_tx_septy   : out   std_logic;                                        -- ff_tx_septy
        tse_mac_mac_misc_connection_tx_ff_uflow   : out   std_logic;                                        -- tx_ff_uflow
        tse_mac_mac_misc_connection_ff_tx_a_full  : out   std_logic;                                        -- ff_tx_a_full
        tse_mac_mac_misc_connection_ff_tx_a_empty : out   std_logic;                                        -- ff_tx_a_empty
        tse_mac_mac_misc_connection_rx_err_stat   : out   std_logic_vector(17 downto 0);                    -- rx_err_stat
        tse_mac_mac_misc_connection_rx_frm_type   : out   std_logic_vector(3 downto 0);                     -- rx_frm_type
        tse_mac_mac_misc_connection_ff_rx_dsav    : out   std_logic;                                        -- ff_rx_dsav
        tse_mac_mac_misc_connection_ff_rx_a_full  : out   std_logic;                                        -- ff_rx_a_full
        tse_mac_mac_misc_connection_ff_rx_a_empty : out   std_logic                                         -- ff_rx_a_empty
    );
    end component Nios;


    --*************************************************************************************
    -- Procedure Definitions
    --*************************************************************************************
    
    --*************************************************************************************
    -- Function Definitions
    --*************************************************************************************

    --*************************************************************************************
    -- Constant Definitions
    --*************************************************************************************
    constant ClkPeriodNanosecond_Con    :       natural := 20;   
    constant ClkPeriodFractNum_Con      :       natural := 0; 
    constant ClkPeriodFractDeNum_Con    :       natural := 0; 
    constant InSyncNanosecond_Con       :       natural := 500; 
    constant AxiNrOfSlaves_Con          :       natural := 3;
    

    
    --*************************************************************************************
    -- Type Definitions
    --*************************************************************************************

    --*************************************************************************************
    -- Signal Definitions
    --*************************************************************************************
    
    -- Rst & Clk
    signal RstCount_CntReg              : natural := 0;
    signal SmiRstN_Rst                  : std_logic;
    signal SysRstN_Rst                  : std_logic;
    signal SysClk_Clk                   : std_logic;
    
    -- Eval
    signal EvalRstN_Rst                 : std_logic := '0';
    signal EvalCount_CntReg             : unsigned(63 downto 0) := to_unsigned(0, 64);
    
    -- Led
    signal BlinkingLed_DatReg           : std_logic;
    signal BlinkingLedCount_CntReg      : natural;
    
    -- Led
    signal UartShift_DatReg             : std_logic_vector(2 downto 0) := (others => '1');
    signal UartLed_DatReg               : std_logic;
    signal UartLedCount_CntReg          : natural;
    
    -- Clock
    signal Mhz25Clk_Clk                 : std_logic;
    signal Mhz25RstN_Rst                : std_logic;
    signal Mhz25RstNShift_DatReg        : std_logic_vector(7 downto 0) := (others => '0');

    signal Mhz50Clk_Clk                 : std_logic;
    signal Mhz50RstN_Rst                : std_logic;
    signal Mhz50RstNShift_DatReg        : std_logic_vector(7 downto 0) := (others => '0');
    
    signal Mhz25PllRst_Rst              : std_logic;
    signal Mhz25PllRstNShift_DatReg     : std_logic_vector(7 downto 0) := (others => '0');
    signal PllLocked_Val                : std_logic;
             
                 
    -- Timer
    signal Timer1ms_Evt                 : std_logic;    
         
    -- Pps
    signal Pps_Evt                      : std_logic;    
    
    -- In Sync Output
    signal InSync_Dat                   : std_logic;
                
    -- Ethernet
    signal Port1MiiRxRstN_Rst           : std_logic;
    signal Port1MiiRxRstNShift_DatReg   : std_logic_vector(7 downto 0) := (others => '0');
    signal Port1MiiTxRstN_Rst           : std_logic;    
    signal Port1MiiTxRstNShift_DatReg   : std_logic_vector(7 downto 0) := (others => '0');
        
    signal Port2MiiRxRstN_Rst           : std_logic;
    signal Port2MiiRxRstNShift_DatReg   : std_logic_vector(7 downto 0) := (others => '0');
    signal Port2MiiTxRstN_Rst           : std_logic;    
    signal Port2MiiTxRstNShift_DatReg   : std_logic_vector(7 downto 0) := (others => '0');
    

    signal eth0_mdio_in                 : std_logic;
    signal eth0_mdio_out                : std_logic;
    signal eth0_mdio_oen                : std_logic;
           
    signal tse_mac_rst_reg              : std_logic;
    

--*****************************************************************************************
-- Architecture Implementation
--*****************************************************************************************
begin

    --*************************************************************************************
    -- Concurrent Statements
    --*************************************************************************************
    Mhz25PllRst_Rst <= not Mhz25PllRstNShift_DatReg(7);
    
    eth0_mdio <= eth0_mdio_out when eth0_mdio_oen = '0' else 'Z';
    eth0_mdio_in <= eth0_mdio;
    
    --Pps_EvtOut <= '0' when (Pps_Evt = '0') else '1'; 
    Led_DatOut(0) <= BlinkingLed_DatReg;
    Led_DatOut(1) <= '0';
    Led_DatOut(2) <= '0';
    Led_DatOut(3) <= '0';
    Led_DatOut(4) <= '0';
    Led_DatOut(5) <= '0';
    Led_DatOut(6) <= '0';
    Led_DatOut(7) <= '0';
    
    sdram_clk <= SysClk_Clk;
    eth0_rst <= tse_mac_rst_reg;
    --*************************************************************************************
    -- Procedural Statements
    --*************************************************************************************
    -- UartLed_Prc : process(EvalRstN_Rst, Mhz50RstN_Rst, Mhz50Clk_Clk) is
    -- begin
        -- if ((EvalRstN_Rst = '0') or (Mhz50RstN_Rst = '0')) then
            -- UartShift_DatReg <= (others => '1');
            -- UartLed_DatReg <= '0';
            -- UartLedCount_CntReg <= 0;
        -- elsif ((Mhz50Clk_Clk'event) and (Mhz50Clk_Clk = '1')) then
            -- if (UartLedCount_CntReg > ClkPeriodNanosecond_Con) then
                -- UartLedCount_CntReg <= UartLedCount_CntReg - ClkPeriodNanosecond_Con;
                -- UartLed_DatReg <= '1';
            -- else
                -- UartLed_DatReg <= '0';
            -- end if;
            -- UartShift_DatReg <= Uart_DatIn & UartShift_DatReg(2 downto 1);
            -- if (UartShift_DatReg(0) /= UartShift_DatReg(1)) then
                -- UartLedCount_CntReg <= 20000000;
            -- end if;
        -- end if;
    -- end process UartLed_Prc;
    
    BlinkingLed_Prc : process(RstN_RstIn, SysClk_Clk) is
    begin
        if (RstN_RstIn = '0') then
            BlinkingLed_DatReg <= '0';
            BlinkingLedCount_CntReg <= 0;
        elsif ((SysClk_Clk'event) and (SysClk_Clk = '1')) then
            if (BlinkingLedCount_CntReg < 250000000) then
                BlinkingLedCount_CntReg <= BlinkingLedCount_CntReg + ClkPeriodNanosecond_Con;
            else
                BlinkingLed_DatReg <= (not BlinkingLed_DatReg);
                BlinkingLedCount_CntReg <= 0;
            end if;
        end if;
    end process BlinkingLed_Prc;
    
    
    Rst_Prc : process(RstN_RstIn, SysClk_Clk) is
    begin
        if (RstN_RstIn = '0') then
            tse_mac_rst_reg <= '0';
            eth1_rst <= '0';
            -- SysRstN_Rst <= '0';
            RstCount_CntReg <= 0;
        elsif ((SysClk_Clk'event) and (SysClk_Clk = '1')) then
            if (RstCount_CntReg < 2000000000) then
                RstCount_CntReg <= RstCount_CntReg + ClkPeriodNanosecond_Con;
                if (RstCount_CntReg < 100000000) then -- 100ms
                    tse_mac_rst_reg <= '0';
                else
                    tse_mac_rst_reg <= '1';
                end if;
                
                if (RstCount_CntReg < 200000000) then -- 200ms

                else
   
                end if;
                
                if (RstCount_CntReg < 1500000000) then -- 1500ms

                else

                end if;
            else
                RstCount_CntReg <= RstCount_CntReg;
                tse_mac_rst_reg <= '1';
                -- SysRstN_Rst <= '1';
            end if;
        end if;
    end process Rst_Prc;
    

    
    Mhz25PllRst_Prc : process(RstN_RstIn, Mhz25Clk_ClkIn) is
    begin
        if (RstN_RstIn = '0') then
            Mhz25PllRstNShift_DatReg <= (others => '0');
        elsif ((Mhz25Clk_ClkIn'event) and (Mhz25Clk_ClkIn = '1')) then
            Mhz25PllRstNShift_DatReg <= Mhz25PllRstNShift_DatReg(6 downto 0) & '1';
        end if;
    end process Mhz25PllRst_Prc;
    
    -- Port1MiiRxRst_Prc : process(SysRstN_Rst, Port1MiiRxClk_ClkIn) is
    -- begin
        -- if (SysRstN_Rst = '0') then
            -- Port1MiiRxRstNShift_DatReg <= (others => '0');
        -- elsif ((Port1MiiRxClk_ClkIn'event) and (Port1MiiRxClk_ClkIn = '1')) then
            -- Port1MiiRxRstNShift_DatReg <= Port1MiiRxRstNShift_DatReg(6 downto 0) & '1';
        -- end if;
    -- end process Port1MiiRxRst_Prc;
    
    -- Port1MiiTxRst_Prc : process(SysRstN_Rst, Port1MiiTxClk_ClkIn) is
    -- begin
        -- if (SysRstN_Rst = '0') then
            -- Port1MiiTxRstNShift_DatReg <= (others => '0');
        -- elsif ((Port1MiiTxClk_ClkIn'event) and (Port1MiiTxClk_ClkIn = '1')) then
            -- Port1MiiTxRstNShift_DatReg <= Port1MiiTxRstNShift_DatReg(6 downto 0) & '1';
        -- end if;
    -- end process Port1MiiTxRst_Prc;
    
    -- Port2MiiRxRst_Prc : process(SysRstN_Rst, Port2MiiRxClk_ClkIn) is
    -- begin
        -- if (SysRstN_Rst = '0') then
            -- Port2MiiRxRstNShift_DatReg <= (others => '0');
        -- elsif ((Port2MiiRxClk_ClkIn'event) and (Port2MiiRxClk_ClkIn = '1')) then
            -- Port2MiiRxRstNShift_DatReg <= Port2MiiRxRstNShift_DatReg(6 downto 0) & '1';
        -- end if;
    -- end process Port2MiiRxRst_Prc;
    
    -- Port2MiiTxRst_Prc : process(SysRstN_Rst, Port2MiiTxClk_ClkIn) is
    -- begin
        -- if (SysRstN_Rst = '0') then
            -- Port2MiiTxRstNShift_DatReg <= (others => '0');
        -- elsif ((Port2MiiTxClk_ClkIn'event) and (Port2MiiTxClk_ClkIn = '1')) then
            -- Port2MiiTxRstNShift_DatReg <= Port2MiiTxRstNShift_DatReg(6 downto 0) & '1';
        -- end if;
    -- end process Port2MiiTxRst_Prc;
    
    --*************************************************************************************
    -- Instations and Port mapping
    --*************************************************************************************
    
    
    u0 : Nios
    port map (
        clk_clk                                     => Mhz25Clk_ClkIn,                         --                clk.clk
        reset_reset_n                               => not Mhz25PllRst_Rst,                    --              reset.reset_n
        
        tse_mac_mac_mdio_connection_mdc             => eth0_mdc,
        tse_mac_mac_mdio_connection_mdio_in         => eth0_mdio_in,
        tse_mac_mac_mdio_connection_mdio_out        => eth0_mdio_out,
        tse_mac_mac_mdio_connection_mdio_oen        => eth0_mdio_oen,
        tse_mac_mac_mii_connection_mii_rx_d         => eth0_rxd,
        tse_mac_mac_mii_connection_mii_rx_dv        => eth0_rxdv,
        tse_mac_mac_mii_connection_mii_rx_err       => eth0_rxer,
        tse_mac_mac_mii_connection_mii_tx_d         => eth0_txd,
        tse_mac_mac_mii_connection_mii_tx_en        => eth0_txen,
        tse_mac_mac_mii_connection_mii_tx_err       => open,
        tse_mac_mac_mii_connection_mii_crs          => eth0_crs,
        tse_mac_mac_mii_connection_mii_col          => eth0_col,
        tse_mac_mac_misc_connection_ff_tx_crc_fwd   => '0',
        tse_mac_mac_misc_connection_ff_tx_septy     => open,
        tse_mac_mac_misc_connection_tx_ff_uflow     => open,
        tse_mac_mac_misc_connection_ff_tx_a_full    => open,
        tse_mac_mac_misc_connection_ff_tx_a_empty   => open,
        tse_mac_mac_misc_connection_rx_err_stat     => open,
        tse_mac_mac_misc_connection_rx_frm_type     => open,
        tse_mac_mac_misc_connection_ff_rx_dsav      => open,
        tse_mac_mac_misc_connection_ff_rx_a_full    => open,
        tse_mac_mac_misc_connection_ff_rx_a_empty   => open,
        tse_mac_mac_status_connection_set_10        => '0',
        tse_mac_mac_status_connection_set_1000      => '0',
        tse_mac_mac_status_connection_eth_mode      => open,
        tse_mac_mac_status_connection_ena_10        => open,
        tse_mac_pcs_mac_rx_clock_connection_clk     => eth0_rxc,
        tse_mac_pcs_mac_tx_clock_connection_clk     => eth0_txc,
        
        sdram_controller_0_addr                     => sdram_0_addr,                           -- sdram_controller_0.addr
        sdram_controller_0_ba                       => sdram_0_ba,                             --                   .ba
        sdram_controller_0_cas_n                    => sdram_0_cas_n,                          --                   .cas_n
        sdram_controller_0_cke                      => sdram_0_cke,                            --                   .cke
        sdram_controller_0_cs_n                     => sdram_0_cs_n,                           --                   .cs_n
        sdram_controller_0_dq                       => sdram_0_dq,                          --                   .dq
        sdram_controller_0_dqm                      => sdram_0_dqm,                           --                   .dqm
        sdram_controller_0_ras_n                    => sdram_0_ras_n,                             --                   .ras_n
        sdram_controller_0_we_n                     => sdram_0_we_n,                            --                   .we_n
        altpll_0_c1_clk                             => SysClk_Clk,
        uart_0_rxd                                  => Uart_DatIn,                             --             uart_0.rxd
        uart_0_txd                                  => Uart_DatOut                             --                   .txd
    );
    

end architecture NiosIITop_Arch;                                             