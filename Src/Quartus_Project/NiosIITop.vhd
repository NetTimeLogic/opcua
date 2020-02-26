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
        Sdram_AddrOut                   : out   std_logic_vector(11 downto 0);
        Sdram_BaOut                     : out   std_logic_vector(1 downto 0);
        Sdram_CasNOut                   : out   std_logic;
        Sdram_CkenOut                   : out   std_logic;
        Sdram_CsNOut                    : out   std_logic;
        Sdram_RasNOut                   : out   std_logic;
        Sdram_WeNOut                    : out   std_logic;
        Sdram_DqInOut                   : inout std_logic_vector(15 downto 0);
        Sdram_DqmOut                    : out   std_logic_vector(1 downto 0);
        Sdram_ClkOut                    : out   std_logic;

        -- Ethernet 1
        -- Smi
        Port1RstN_RstOut                : out   std_logic;
        Port1SmiMdc_ClkOut              : out   std_logic;
        Port1SmiMdio_DatInOut           : inout std_logic;
        
        -- Mii Clk Input
        Port1MiiRxClk_ClkIn             : in    std_logic;
        
        -- Mii Clk Input
        Port1MiiTxClk_ClkIn             : in    std_logic;
        
        -- Mii Output
        Port1MiiTxEn_EnaOut             : out   std_logic;
        Port1MiiTxData_DatOut           : out   std_logic_vector(3 downto 0);
        
        -- Mii Input
        Port1MiiRxDv_EnaIn              : in    std_logic;
        Port1MiiRxErr_ErrIn             : in    std_logic;
        Port1MiiRxData_DatIn            : in    std_logic_vector(3 downto 0);

        Port1MiiCol_DatIn               : in    std_logic;
        Port1MiiCrs_DatIn               : in    std_logic;
        
        -- Ethernet 2
        Port2RstN_RstOut                : out   std_logic
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
        clk_clk                                   : in    std_logic                     := 'X';             -- clk
        clk_300_clk                               : out   std_logic;                                        -- clk
        clk_sdram_clk                             : out   std_logic;                                        -- clk
        locked_export                             : out   std_logic;                                        -- export
        reset_reset_n                             : in    std_logic                     := 'X';             -- reset_n
        reset_bridge_0_in_reset_reset_n           : in    std_logic                     := 'X';             -- reset_n
        sdram_controller_0_addr                   : out   std_logic_vector(11 downto 0);                    -- addr
        sdram_controller_0_ba                     : out   std_logic_vector(1 downto 0);                     -- ba
        sdram_controller_0_cas_n                  : out   std_logic;                                        -- cas_n
        sdram_controller_0_cke                    : out   std_logic;                                        -- cke
        sdram_controller_0_cs_n                   : out   std_logic;                                        -- cs_n
        sdram_controller_0_dq                     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
        sdram_controller_0_dqm                    : out   std_logic_vector(1 downto 0);                     -- dqm
        sdram_controller_0_ras_n                  : out   std_logic;                                        -- ras_n
        sdram_controller_0_we_n                   : out   std_logic;                                        -- we_n
        sys_clk_clk                               : out   std_logic;                                        -- clk
        tse_mac_mac_mdio_connection_mdc           : out   std_logic;                                        -- mdc
        tse_mac_mac_mdio_connection_mdio_in       : in    std_logic                     := 'X';             -- mdio_in
        tse_mac_mac_mdio_connection_mdio_out      : out   std_logic;                                        -- mdio_out
        tse_mac_mac_mdio_connection_mdio_oen      : out   std_logic;                                        -- mdio_oen
        tse_mac_mac_mii_connection_mii_rx_d       : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- mii_rx_d
        tse_mac_mac_mii_connection_mii_rx_dv      : in    std_logic                     := 'X';             -- mii_rx_dv
        tse_mac_mac_mii_connection_mii_rx_err     : in    std_logic                     := 'X';             -- mii_rx_err
        tse_mac_mac_mii_connection_mii_tx_d       : out   std_logic_vector(3 downto 0);                     -- mii_tx_d
        tse_mac_mac_mii_connection_mii_tx_en      : out   std_logic;                                        -- mii_tx_en
        tse_mac_mac_mii_connection_mii_tx_err     : out   std_logic;                                        -- mii_tx_err
        tse_mac_mac_mii_connection_mii_crs        : in    std_logic                     := 'X';             -- mii_crs
        tse_mac_mac_mii_connection_mii_col        : in    std_logic                     := 'X';             -- mii_col
        tse_mac_mac_misc_connection_ff_tx_crc_fwd : in    std_logic                     := 'X';             -- ff_tx_crc_fwd
        tse_mac_mac_misc_connection_ff_tx_septy   : out   std_logic;                                        -- ff_tx_septy
        tse_mac_mac_misc_connection_tx_ff_uflow   : out   std_logic;                                        -- tx_ff_uflow
        tse_mac_mac_misc_connection_ff_tx_a_full  : out   std_logic;                                        -- ff_tx_a_full
        tse_mac_mac_misc_connection_ff_tx_a_empty : out   std_logic;                                        -- ff_tx_a_empty
        tse_mac_mac_misc_connection_rx_err_stat   : out   std_logic_vector(17 downto 0);                    -- rx_err_stat
        tse_mac_mac_misc_connection_rx_frm_type   : out   std_logic_vector(3 downto 0);                     -- rx_frm_type
        tse_mac_mac_misc_connection_ff_rx_dsav    : out   std_logic;                                        -- ff_rx_dsav
        tse_mac_mac_misc_connection_ff_rx_a_full  : out   std_logic;                                        -- ff_rx_a_full
        tse_mac_mac_misc_connection_ff_rx_a_empty : out   std_logic;                                        -- ff_rx_a_empty
        tse_mac_mac_status_connection_set_10      : in    std_logic                     := 'X';             -- set_10
        tse_mac_mac_status_connection_set_1000    : in    std_logic                     := 'X';             -- set_1000
        tse_mac_mac_status_connection_eth_mode    : out   std_logic;                                        -- eth_mode
        tse_mac_mac_status_connection_ena_10      : out   std_logic;                                        -- ena_10
        tse_mac_pcs_mac_rx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
        tse_mac_pcs_mac_tx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
        uart_0_rxd                                : in    std_logic                     := 'X';             -- rxd
        uart_0_txd                                : out   std_logic                                         -- txd
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
                   
    -- Ethernet 
    signal Port1SmiMdio_DatIn           : std_logic;
    signal Port1SmiMdio_DatOut          : std_logic;
    signal Port1SmiMdio_DatOut_Oen      : std_logic;
           
    

--*****************************************************************************************
-- Architecture Implementation
--*****************************************************************************************
begin

    --*************************************************************************************
    -- Concurrent Statements
    --*************************************************************************************
    Mhz25PllRst_Rst <= not Mhz25PllRstNShift_DatReg(7);
    Mhz50RstN_Rst <= Mhz50RstNShift_DatReg(7);
    
    Port1SmiMdio_DatInOut <= Port1SmiMdio_DatOut when Port1SmiMdio_DatOut_Oen = '0' else 'Z';
    Port1SmiMdio_DatIn <= Port1SmiMdio_DatInOut;
    
    --Pps_EvtOut <= '0' when (Pps_Evt = '0') else '1'; 
    Led_DatOut(0) <= BlinkingLed_DatReg;
    Led_DatOut(1) <= '0';
    Led_DatOut(2) <= '0';
    Led_DatOut(3) <= '0';
    Led_DatOut(4) <= '0';
    Led_DatOut(5) <= '0';
    Led_DatOut(6) <= '0';
    Led_DatOut(7) <= '0';




    --*************************************************************************************
    -- Procedural Statements
    --*************************************************************************************
    
    BlinkingLed_Prc : process(Mhz50RstN_Rst, Mhz50Clk_Clk) is
    begin
        if (Mhz50RstN_Rst = '0') then
            BlinkingLed_DatReg <= '0';
            BlinkingLedCount_CntReg <= 0;
        elsif ((Mhz50Clk_Clk'event) and (Mhz50Clk_Clk = '1')) then
            if (BlinkingLedCount_CntReg < 250000000) then
                BlinkingLedCount_CntReg <= BlinkingLedCount_CntReg + ClkPeriodNanosecond_Con;
            else
                BlinkingLed_DatReg <= (not BlinkingLed_DatReg);
                BlinkingLedCount_CntReg <= 0;
            end if;
        end if;
    end process BlinkingLed_Prc;
    
    
    Rst_Prc : process(Mhz50RstN_Rst, Mhz50Clk_Clk) is
    begin
        if (Mhz50RstN_Rst = '0') then
            Port1RstN_RstOut <= '1';
            Port2RstN_RstOut <= '0';
            SysRstN_Rst <= '0';
            RstCount_CntReg <= 0;
        elsif ((Mhz50Clk_Clk'event) and (Mhz50Clk_Clk = '1')) then
            if (RstCount_CntReg < 2000000000) then
                RstCount_CntReg <= RstCount_CntReg + ClkPeriodNanosecond_Con;
                if (RstCount_CntReg < 100000000) then -- 100ms
                    Port1RstN_RstOut <= '1';
                else
                    Port1RstN_RstOut <= '1';
                end if;
                
                if (RstCount_CntReg < 1000000000) then -- 1000ms
                    SysRstN_Rst <= '0';
                else
                    SysRstN_Rst <= '1';
                end if;
                
            else
                RstCount_CntReg <= RstCount_CntReg;
                Port1RstN_RstOut <= '1';
                SysRstN_Rst <= '1';
            end if;
        end if;
    end process Rst_Prc;
    
    Mhz50Rst_Prc : process(PllLocked_Val, Mhz25PllRst_Rst, Mhz50Clk_Clk) is
    begin
        if ((PllLocked_Val = '0') or (Mhz25PllRst_Rst = '1')) then
            Mhz50RstNShift_DatReg <= (others => '0');
        elsif ((Mhz50Clk_Clk'event) and (Mhz50Clk_Clk = '1')) then
            Mhz50RstNShift_DatReg <= Mhz50RstNShift_DatReg(6 downto 0) & '1';
        end if;
    end process Mhz50Rst_Prc;
    
    Mhz25PllRst_Prc : process(RstN_RstIn, Mhz25Clk_ClkIn) is
    begin
        if (RstN_RstIn = '0') then
            Mhz25PllRstNShift_DatReg <= (others => '0');
        elsif ((Mhz25Clk_ClkIn'event) and (Mhz25Clk_ClkIn = '1')) then
            Mhz25PllRstNShift_DatReg <= Mhz25PllRstNShift_DatReg(6 downto 0) & '1';
        end if;
    end process Mhz25PllRst_Prc;
   
    --*************************************************************************************
    -- Instantiations and Port mapping
    --*************************************************************************************
    
    u0 : Nios
    port map (
        clk_clk                                     => Mhz25Clk_ClkIn,
        reset_reset_n                               => not Mhz25PllRst_Rst,
        
        sys_clk_clk                                 => Mhz50Clk_Clk,
        reset_bridge_0_in_reset_reset_n             => SysRstN_Rst,
        
        clk_sdram_clk                               => Sdram_ClkOut,
        clk_300_clk                                 => open,
        locked_export                               => PllLocked_Val,
        
        tse_mac_mac_mdio_connection_mdc             => Port1SmiMdc_ClkOut,
        tse_mac_mac_mdio_connection_mdio_in         => Port1SmiMdio_DatIn,
        tse_mac_mac_mdio_connection_mdio_out        => Port1SmiMdio_DatOut,
        tse_mac_mac_mdio_connection_mdio_oen        => Port1SmiMdio_DatOut_Oen,
        tse_mac_mac_mii_connection_mii_rx_d         => Port1MiiRxData_DatIn,
        tse_mac_mac_mii_connection_mii_rx_dv        => Port1MiiRxDv_EnaIn,
        tse_mac_mac_mii_connection_mii_rx_err       => Port1MiiRxErr_ErrIn,
        tse_mac_mac_mii_connection_mii_tx_d         => Port1MiiTxData_DatOut,
        tse_mac_mac_mii_connection_mii_tx_en        => Port1MiiTxEn_EnaOut,
        tse_mac_mac_mii_connection_mii_tx_err       => open,
        tse_mac_mac_mii_connection_mii_crs          => Port1MiiCrs_DatIn,
        tse_mac_mac_mii_connection_mii_col          => Port1MiiCol_DatIn,
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
        tse_mac_pcs_mac_rx_clock_connection_clk     => Port1MiiRxClk_ClkIn,
        tse_mac_pcs_mac_tx_clock_connection_clk     => Port1MiiTxClk_ClkIn,
        
        sdram_controller_0_addr                     => Sdram_AddrOut,
        sdram_controller_0_ba                       => Sdram_BaOut,  
        sdram_controller_0_cas_n                    => Sdram_CasNOut,
        sdram_controller_0_cke                      => Sdram_CkenOut,
        sdram_controller_0_cs_n                     => Sdram_CsNOut, 
        sdram_controller_0_dq                       => Sdram_DqInOut,
        sdram_controller_0_dqm                      => Sdram_DqmOut, 
        sdram_controller_0_ras_n                    => Sdram_RasNOut,
        sdram_controller_0_we_n                     => Sdram_WeNOut, 

        uart_0_rxd                                  => Uart_DatIn,   
        uart_0_txd                                  => Uart_DatOut   
    );
    

end architecture NiosIITop_Arch;                                             