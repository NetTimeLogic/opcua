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
library CommonLib;
use CommonLib.Common_Package.all;
use CommonLib.Common_EthernetPackage.all;

library ClkLib;
use ClkLib.Clk_Package.all;
use ClkLib.Clk_ClockAddrPackage.all;

library AxiLib;
use AxiLib.Axi_Package.all;

library TsnLib;
use TsnLib.Tsn_Package.all;

library RedLib;
use RedLib.Red_Package.all;
use RedLib.Red_TsnAddrPackage.all;

library PtpLib;
use PtpLib.Ptp_Package.all;
use PtpLib.Ptp_OrdinaryClockAddrPackage.all;
use PtpLib.Ptp_TransparentClockAddrPackage.all;

library ConfLib;
use ConfLib.Conf_Package.all;

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
        Sdram_AddrOut                   : out   std_logic_vector(12 downto 0);
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
        PortCpuRstN_RstOut                : out   std_logic
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
        clk_sdram_clk                             : out   std_logic;                                        -- clk
        --clk_300mhz_clk                            : out   std_logic;                                         -- clk
        locked_export                             : out   std_logic;                                        -- export
        reset_reset_n                             : in    std_logic                     := 'X';             -- reset_n
        reset_bridge_0_in_reset_reset_n           : in    std_logic                     := 'X';             -- reset_n
        sdram_controller_0_addr                   : out   std_logic_vector(12 downto 0);                    -- addr
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
        m_axi_ext_awaddr                          : out   std_logic_vector(27 downto 0);                    -- awaddr
        m_axi_ext_awprot                          : out   std_logic_vector(2 downto 0);                     -- awprot
        m_axi_ext_awvalid                         : out   std_logic;                                        -- awvalid
        m_axi_ext_awready                         : in    std_logic                     := 'X';             -- awready
        m_axi_ext_wdata                           : out   std_logic_vector(31 downto 0);                    -- wdata
        m_axi_ext_wstrb                           : out   std_logic_vector(3 downto 0);                     -- wstrb
        m_axi_ext_wlast                           : out   std_logic;                                        -- wlast
        m_axi_ext_wvalid                          : out   std_logic;                                        -- wvalid
        m_axi_ext_wready                          : in    std_logic                     := 'X';             -- wready
        m_axi_ext_bresp                           : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- bresp
        m_axi_ext_bvalid                          : in    std_logic                     := 'X';             -- bvalid
        m_axi_ext_bready                          : out   std_logic;                                        -- bready
        m_axi_ext_araddr                          : out   std_logic_vector(27 downto 0);                    -- araddr
        m_axi_ext_arprot                          : out   std_logic_vector(2 downto 0);                     -- arprot
        m_axi_ext_arvalid                         : out   std_logic;                                        -- arvalid
        m_axi_ext_arready                         : in    std_logic                     := 'X';             -- arready
        m_axi_ext_rdata                           : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rdata
        m_axi_ext_rresp                           : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rresp
        m_axi_ext_rvalid                          : in    std_logic                     := 'X';             -- rvalid
        m_axi_ext_rready                          : out   std_logic;                                        -- rready

        irq_bridge_0_receiver_irq_irq             : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- irq
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
    constant ClkPeriodNanosecond_Con    :       natural := 10;
    constant ClkPeriodFractNum_Con      :       natural := 0;
    constant ClkPeriodFractDeNum_Con    :       natural := 0;
    constant InSyncNanosecond_Con       :       natural := 500;
    constant AxiNrOfSlaves_Con          :       natural := 3;
    constant AxiNrOfMasters_Con         :       natural := 2;
    
    constant Configs_Con :  Conf_Config_Type(255 downto 0) := (
                                                    0 => (
                                                        CoreType            => Conf_RedTsnCoreType_Con,
                                                        CoreInstanceNr      => 1,
                                                        AddressRangeLow     => x"60000000",
                                                        AddressRangeHigh    => x"60000FFF",
                                                        InterruptMask       => x"00000000"),
                                                    1 => (
                                                        CoreType            => Conf_ClkClockCoreType_Con,
                                                        CoreInstanceNr      => 1,
                                                        AddressRangeLow     => x"60010000",
                                                        AddressRangeHigh    => x"6001FFFF",
                                                        InterruptMask       => x"00000000"),
                                                    2 => (
                                                        CoreType            => Conf_PtpHybridClockCoreType_Con,
                                                        CoreInstanceNr      => 1,
                                                        AddressRangeLow     => x"60001000",
                                                        AddressRangeHigh    => x"6000FFFF",
                                                        InterruptMask       => x"00000000"),
                                                    3 => (
                                                        CoreType            => Conf_ClkSignalGeneratorCoreType_Con,
                                                        CoreInstanceNr      => 1,
                                                        AddressRangeLow     => x"60020000",
                                                        AddressRangeHigh    => x"6002FFFF",
                                                        InterruptMask       => x"00000000"),    
                                                    others => Conf_ConfigEntry_Type_Rst_Con);
                                                        
    constant NumberOfConfigs_Con        :       natural := 4;   
    
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

    signal Mhz100Clk_Clk                 : std_logic;
    signal Mhz300Clk_Clk                : std_logic;
    signal Mhz100RstN_Rst                : std_logic;
    signal Mhz100RstNShift_DatReg        : std_logic_vector(7 downto 0) := (others => '0');
    
    signal Mhz25PllRst_Rst              : std_logic;
    signal Mhz25PllRstNShift_DatReg     : std_logic_vector(7 downto 0) := (others => '0');
    signal PllLocked_Val                : std_logic;
                   
        -- Alive 
    signal Alive_Dat                    : std_logic;
    
    -- Timer
    signal Timer1ms_Evt                 : std_logic;    
    
    -- Pps
    signal Pps_Evt                      : std_logic;    

    -- In Sync Output
    signal InSync_Dat                   : std_logic;
    
    -- Signal Output
    signal SignalGenerator_Evt          : std_logic; 
    signal Irq_Evt                      : std_logic; 
    
    -- Time Input   
    signal ClockTime_Dat                : Clk_Time_Type;
    signal ClockTime_Val                : std_logic;

    -- Time Adjustment        
    signal TimeAdjustmentPtp_Dat        : Clk_TimeAdjustment_Type;
    signal TimeAdjustmentPtp_Val        : std_logic; 
                                            
    -- Offset Adjustment             
    signal OffsetAdjustmentPtp_Dat      : Clk_TimeAdjustment_Type;
    signal OffsetAdjustmentPtp_Val      : std_logic;
                                             
    -- Drift Adjustment                
    signal DriftAdjustmentPtp_Dat       : Clk_TimeAdjustment_Type;
    signal DriftAdjustmentPtp_Val       : std_logic;
         
    -- Drift Adjustment        
    signal DriftAdjustment_Dat          : Clk_TimeAdjustment_Type;
    signal DriftAdjustment_Val          : std_logic;
                                                
    -- Offset Adjustment                
    signal OffsetAdjustment_Dat         : Clk_TimeAdjustment_Type;
    signal OffsetAdjustment_Val         : std_logic;               
                   
                   
    -- Ethernet 
    signal Port1SmiMdio_DatIn           : std_logic;
    signal Port1SmiMdio_DatOut          : std_logic;
    signal Port1SmiMdio_DatOut_Oen      : std_logic;
    
    -- Mii Output                   
    signal PortXMiiRxDv_Ena             : std_logic;
    signal PortXMiiRxErr_Err            : std_logic;
    signal PortXMiiRxData_Dat           : std_logic_vector(3 downto 0);
         
    signal PortXMiiCol_Dat              : std_logic;
    signal PortXMiiCrs_Dat              : std_logic;
                                           
    -- Mii Input                           
    signal PortXMiiTxEn_Ena             : std_logic;
    signal PortXMiiTxErr_Err            : std_logic;
    signal PortXMiiTxData_Dat           : std_logic_vector(3 downto 0);
           
        -- Axi   
    signal AxiSWriteAddrValid_Val       : Axi_ItfValid_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteAddrReady_Rdy       : Axi_ItfReady_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteAddrAddress_Adr     : Axi_ItfAddress_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteAddrProt_Dat        : Axi_ItfProt_Type((AxiNrOfMasters_Con-1) downto 0);
                                        
    signal AxiSWriteDataValid_Val       : Axi_ItfValid_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteDataReady_Rdy       : Axi_ItfReady_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteDataData_Dat        : Axi_ItfData_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteDataStrobe_Dat      : Axi_ItfStrobe_Type((AxiNrOfMasters_Con-1) downto 0);
                                        
    signal AxiSWriteRespValid_Val       : Axi_ItfValid_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteRespReady_Rdy       : Axi_ItfReady_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSWriteRespResponse_Dat    : Axi_ItfResponse_Type((AxiNrOfMasters_Con-1) downto 0);
                                        
    signal AxiSReadAddrValid_Val        : Axi_ItfValid_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadAddrReady_Rdy        : Axi_ItfReady_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadAddrAddress_Adr      : Axi_ItfAddress_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadAddrProt_Dat         : Axi_ItfProt_Type((AxiNrOfMasters_Con-1) downto 0);
                                        
    signal AxiSReadDataValid_Val        : Axi_ItfValid_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadDataReady_Rdy        : Axi_ItfReady_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadDataResponse_Dat     : Axi_ItfResponse_Type((AxiNrOfMasters_Con-1) downto 0);
    signal AxiSReadDataData_Dat         : Axi_ItfData_Type((AxiNrOfMasters_Con-1) downto 0);
    
    -- Axi
    signal AxiMWriteAddrValid_Val       : Axi_ItfValid_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteAddrReady_Rdy       : Axi_ItfReady_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteAddrAddress_Adr     : Axi_ItfAddress_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteAddrProt_Dat        : Axi_ItfProt_Type((AxiNrOfSlaves_Con-1) downto 0);

    signal AxiMWriteDataValid_Val       : Axi_ItfValid_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteDataReady_Rdy       : Axi_ItfReady_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteDataData_Dat        : Axi_ItfData_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteDataStrobe_Dat      : Axi_ItfStrobe_Type((AxiNrOfSlaves_Con-1) downto 0);

    signal AxiMWriteRespValid_Val       : Axi_ItfValid_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteRespReady_Rdy       : Axi_ItfReady_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMWriteRespResponse_Dat    : Axi_ItfResponse_Type((AxiNrOfSlaves_Con-1) downto 0);

    signal AxiMReadAddrValid_Val        : Axi_ItfValid_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadAddrReady_Rdy        : Axi_ItfReady_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadAddrAddress_Adr      : Axi_ItfAddress_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadAddrProt_Dat         : Axi_ItfProt_Type((AxiNrOfSlaves_Con-1) downto 0);

    signal AxiMReadDataValid_Val        : Axi_ItfValid_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadDataReady_Rdy        : Axi_ItfReady_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadDataResponse_Dat     : Axi_ItfResponse_Type((AxiNrOfSlaves_Con-1) downto 0);
    signal AxiMReadDataData_Dat         : Axi_ItfData_Type((AxiNrOfSlaves_Con-1) downto 0);
    
    -- Axi Input
    signal AxisRxValid_Val              : std_logic;
    signal AxisRxReady_Val              : std_logic;       
    signal AxisRxData_Dat               : std_logic_vector(31 downto 0);
    signal AxisRxStrobe_Val             : std_logic_vector(3 downto 0);
    signal AxisRxKeep_Val               : std_logic_vector(3 downto 0);
    signal AxisRxLast_Val               : std_logic;
    signal AxisRxUser_Dat               : std_logic_vector(2 downto 0);
        
    -- Axi Output
    signal AxisTxValid_Val              : std_logic;
    signal AxisTxReady_Val              : std_logic;       
    signal AxisTxData_Dat               : std_logic_vector(31 downto 0);
    signal AxisTxStrobe_Val             : std_logic_vector(3 downto 0);
    signal AxisTxKeep_Val               : std_logic_vector(3 downto 0);
    signal AxisTxLast_Val               : std_logic;
    signal AxisTxUser_Dat               : std_logic_vector(2 downto 0);      

--*****************************************************************************************
-- Architecture Implementation
--*****************************************************************************************
begin

    --*************************************************************************************
    -- Concurrent Statements
    --*************************************************************************************
    Mhz25PllRst_Rst <= not Mhz25PllRstNShift_DatReg(7);
    Mhz100RstN_Rst <= Mhz100RstNShift_DatReg(7);
    
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
    
    BlinkingLed_Prc : process(Mhz100RstN_Rst, Mhz100Clk_Clk) is
    begin
        if (Mhz100RstN_Rst = '0') then
            BlinkingLed_DatReg <= '0';
            BlinkingLedCount_CntReg <= 0;
        elsif ((Mhz100Clk_Clk'event) and (Mhz100Clk_Clk = '1')) then
            if (BlinkingLedCount_CntReg < 250000000) then
                BlinkingLedCount_CntReg <= BlinkingLedCount_CntReg + ClkPeriodNanosecond_Con;
            else
                BlinkingLed_DatReg <= (not BlinkingLed_DatReg);
                BlinkingLedCount_CntReg <= 0;
            end if;
        end if;
    end process BlinkingLed_Prc;
    
    
    Rst_Prc : process(Mhz100RstN_Rst, Mhz100Clk_Clk) is
    begin
        if (Mhz100RstN_Rst = '0') then
            Port1RstN_RstOut <= '1';
            PortCpuRstN_RstOut <= '0';
            SysRstN_Rst <= '0';
            RstCount_CntReg <= 0;
        elsif ((Mhz100Clk_Clk'event) and (Mhz100Clk_Clk = '1')) then
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
    
    Mhz100Rst_Prc : process(PllLocked_Val, Mhz25PllRst_Rst, Mhz100Clk_Clk) is
    begin
        if ((PllLocked_Val = '0') or (Mhz25PllRst_Rst = '1')) then
            Mhz100RstNShift_DatReg <= (others => '0');
        elsif ((Mhz100Clk_Clk'event) and (Mhz100Clk_Clk = '1')) then
            Mhz100RstNShift_DatReg <= Mhz100RstNShift_DatReg(6 downto 0) & '1';
        end if;
    end process Mhz100Rst_Prc;
    
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
        
        sys_clk_clk                                 => Mhz100Clk_Clk,
        --clk_300mhz_clk                              => Mhz300Clk_Clk,
        reset_bridge_0_in_reset_reset_n             => SysRstN_Rst,
        
        clk_sdram_clk                               => Sdram_ClkOut,
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
       
        M_AXI_EXT_awvalid                           => AxiSWriteAddrValid_Val(1),   
        M_AXI_EXT_awready                           => AxiSWriteAddrReady_Rdy(1),  
        M_AXI_EXT_awaddr                            => AxiSWriteAddrAddress_Adr(1),
        M_AXI_EXT_awprot                            => AxiSWriteAddrProt_Dat(1),
                                                                                            
        M_AXI_EXT_wvalid                            => AxiSWriteDataValid_Val(1),   
        M_AXI_EXT_wready                            => AxiSWriteDataReady_Rdy(1),  
        M_AXI_EXT_wdata                             => AxiSWriteDataData_Dat(1),
        M_AXI_EXT_wstrb                             => AxiSWriteDataStrobe_Dat(1),
                                                                                            
        M_AXI_EXT_bvalid                            => AxiSWriteRespValid_Val(1),  
        M_AXI_EXT_bready                            => AxiSWriteRespReady_Rdy(1),   
        M_AXI_EXT_bresp                             => AxiSWriteRespResponse_Dat(1),
                                                                                        
        M_AXI_EXT_arvalid                           => AxiSReadAddrValid_Val(1),    
        M_AXI_EXT_arready                           => AxiSReadAddrReady_Rdy(1),   
        M_AXI_EXT_araddr                            => AxiSReadAddrAddress_Adr(1),
        M_AXI_EXT_arprot                            => AxiSReadAddrProt_Dat(1),    
                                                                                            
        M_AXI_EXT_rvalid                            => AxiSReadDataValid_Val(1),
        M_AXI_EXT_rready                            => AxiSReadDataReady_Rdy(1),
        M_AXI_EXT_rdata                             => AxiSReadDataData_Dat(1),
        M_AXI_EXT_rresp                             => AxiSReadDataResponse_Dat(1),
        
        irq_bridge_0_receiver_irq_irq(0)            => SignalGenerator_Evt,
        irq_bridge_0_receiver_irq_irq(1)            => Irq_Evt,
        
        uart_0_rxd                                  => Uart_DatIn,   
        uart_0_txd                                  => Uart_DatOut 
        
    );
    
    AxiSWriteAddrAddress_Adr(1)(31 downto 28) <= x"0";
    AxiSReadAddrAddress_Adr(1)(31 downto 28) <= x"0";
    
    ConfSlave_Inst : entity ConfLib.Conf_SlaveUart
    generic map (
        Configs_Gen                     => Configs_Con,           
        NumberOfConfigs_Gen             => NumberOfConfigs_Con,
        UartBaudRate_Gen                => 1000000,
        ClockClkPeriodNanosecond_Gen    => ClkPeriodNanosecond_Con,
        AxiAddressRangeLow_Gen          => x"00000000",
        AxiAddressRangeHigh_Gen         => x"0FFFFFFF"
    )
    port map (
        -- System
        SysClk_ClkIn                    => SysClk_Clk,         
        SysRstN_RstIn                   => SysRstN_Rst,        
                                         
        -- Uart Input                   
        Uart_DatIn                      => Uart_DatIn,           
                                         
        -- Uart Output                  
        Uart_DatOut                     => Uart_DatOut, 
        
        -- Axi
        AxiWriteAddrValid_ValOut        => AxiSWriteAddrValid_Val(0),   
        AxiWriteAddrReady_RdyIn         => AxiSWriteAddrReady_Rdy(0),  
        AxiWriteAddrAddress_AdrOut      => AxiSWriteAddrAddress_Adr(0),
        AxiWriteAddrProt_DatOut         => AxiSWriteAddrProt_Dat(0),
                                               
        AxiWriteDataValid_ValOut        => AxiSWriteDataValid_Val(0),   
        AxiWriteDataReady_RdyIn         => AxiSWriteDataReady_Rdy(0),  
        AxiWriteDataData_DatOut         => AxiSWriteDataData_Dat(0),
        AxiWriteDataStrobe_DatOut       => AxiSWriteDataStrobe_Dat(0),
                                               
        AxiWriteRespValid_ValIn         => AxiSWriteRespValid_Val(0),  
        AxiWriteRespReady_RdyOut        => AxiSWriteRespReady_Rdy(0),   
        AxiWriteRespResponse_DatIn      => AxiSWriteRespResponse_Dat(0),
                                               
        AxiReadAddrValid_ValOut         => AxiSReadAddrValid_Val(0),    
        AxiReadAddrReady_RdyIn          => AxiSReadAddrReady_Rdy(0),   
        AxiReadAddrAddress_AdrOut       => AxiSReadAddrAddress_Adr(0),
        AxiReadAddrProt_DatOut          => AxiSReadAddrProt_Dat(0),    
                                               
        AxiReadDataValid_ValIn          => AxiSReadDataValid_Val(0),   
        AxiReadDataReady_RdyOut         => AxiSReadDataReady_Rdy(0),    
        AxiReadDataResponse_DatIn       => AxiSReadDataResponse_Dat(0),
        AxiReadDataData_DatIn           => AxiSReadDataData_Dat(0)
    );
    
    Interconnect_Inst : entity AxiLib.Axi_InterconnectMultiMaster
    generic map (
        AxiNrOfMasters_Gen              => AxiNrOfMasters_Con,
        AxiNrOfSlaves_Gen               => AxiNrOfSlaves_Con
    )
    port map (        
        -- System
        SysClk_ClkIn                    => SysClk_Clk,              
        SysRstN_RstIn                   => SysRstN_Rst,             
        
        -- Axi
        AxiSWriteAddrValid_ValIn        => AxiSWriteAddrValid_Val,   
        AxiSWriteAddrReady_RdyOut       => AxiSWriteAddrReady_Rdy,  
        AxiSWriteAddrAddress_AdrIn      => AxiSWriteAddrAddress_Adr,
        AxiSWriteAddrProt_DatIn         => AxiSWriteAddrProt_Dat,
                                               
        AxiSWriteDataValid_ValIn        => AxiSWriteDataValid_Val,   
        AxiSWriteDataReady_RdyOut       => AxiSWriteDataReady_Rdy,  
        AxiSWriteDataData_DatIn         => AxiSWriteDataData_Dat,
        AxiSWriteDataStrobe_DatIn       => AxiSWriteDataStrobe_Dat,
                                               
        AxiSWriteRespValid_ValOut       => AxiSWriteRespValid_Val,  
        AxiSWriteRespReady_RdyIn        => AxiSWriteRespReady_Rdy,   
        AxiSWriteRespResponse_DatOut    => AxiSWriteRespResponse_Dat,
                                               
        AxiSReadAddrValid_ValIn         => AxiSReadAddrValid_Val,    
        AxiSReadAddrReady_RdyOut        => AxiSReadAddrReady_Rdy,   
        AxiSReadAddrAddress_AdrIn       => AxiSReadAddrAddress_Adr,
        AxiSReadAddrProt_DatIn          => AxiSReadAddrProt_Dat,    
                                               
        AxiSReadDataValid_ValOut        => AxiSReadDataValid_Val,   
        AxiSReadDataReady_RdyIn         => AxiSReadDataReady_Rdy,    
        AxiSReadDataResponse_DatOut     => AxiSReadDataResponse_Dat,
        AxiSReadDataData_DatOut         => AxiSReadDataData_Dat,
        
        -- Axi
        AxiMWriteAddrValid_ValOut       => AxiMWriteAddrValid_Val,  
        AxiMWriteAddrReady_RdyIn        => AxiMWriteAddrReady_Rdy,   
        AxiMWriteAddrAddress_AdrOut     => AxiMWriteAddrAddress_Adr,
        AxiMWriteAddrProt_DatOut        => AxiMWriteAddrProt_Dat,   
                                                               
        AxiMWriteDataValid_ValOut       => AxiMWriteDataValid_Val,  
        AxiMWriteDataReady_RdyIn        => AxiMWriteDataReady_Rdy,   
        AxiMWriteDataData_DatOut        => AxiMWriteDataData_Dat,   
        AxiMWriteDataStrobe_DatOut      => AxiMWriteDataStrobe_Dat, 
                                                                    
        AxiMWriteRespValid_ValIn        => AxiMWriteRespValid_Val,   
        AxiMWriteRespReady_RdyOut       => AxiMWriteRespReady_Rdy,  
        AxiMWriteRespResponse_DatIn     => AxiMWriteRespResponse_Dat,
                                                                 
        AxiMReadAddrValid_ValOut        => AxiMReadAddrValid_Val,   
        AxiMReadAddrReady_RdyIn         => AxiMReadAddrReady_Rdy,    
        AxiMReadAddrAddress_AdrOut      => AxiMReadAddrAddress_Adr, 
        AxiMReadAddrProt_DatOut         => AxiMReadAddrProt_Dat,    
                                                                   
        AxiMReadDataValid_ValIn         => AxiMReadDataValid_Val,    
        AxiMReadDataReady_RdyOut        => AxiMReadDataReady_Rdy,   
        AxiMReadDataResponse_DatIn      => AxiMReadDataResponse_Dat, 
        AxiMReadDataData_DatIn          => AxiMReadDataData_Dat     
    ); 
   
    ClkClock_Inst : entity ClkLib.Clk_Clock
    generic map (
        StaticConfig_Gen                => false,
        DefaultSelect_Gen               => std_logic_vector(to_unsigned(Clk_ClockSelect_Ptp_Con, 16)),
        ClockClkPeriodNanosecond_Gen    => ClkPeriodNanosecond_Con,
        ClockClkPeriodFractNum_Gen      => ClkPeriodFractNum_Con,  
        ClockClkPeriodFractDeNum_Gen    => ClkPeriodFractDeNum_Con,
        ClockInSyncNanosecond_Gen       => InSyncNanosecond_Con,   
        ExportDrift_Gen                 => true,
        LogCorrections_Gen              => true,
        BypassServo_Gen                 => false,
        DynamicServoParameters_Gen      => false,
        DriftMulP_Gen                   => 3, 
        DriftDivP_Gen                   => 4, 
        DriftMulI_Gen                   => 3, 
        DriftDivI_Gen                   => 16,
        OffsetMulP_Gen                  => 3, 
        OffsetDivP_Gen                  => 4, 
        OffsetMulI_Gen                  => 3, 
        OffsetDivI_Gen                  => 16,   
        AxiAddressRangeLow_Gen          => Configs_Con(1).AddressRangeLow,
        AxiAddressRangeHigh_Gen         => Configs_Con(1).AddressRangeHigh
    )
    port map (
        -- System
        SysClk_ClkIn                    => SysClk_Clk,
        SysRstN_RstIn                   => SysRstN_Rst,
        
        -- Config
        StaticConfig_DatIn              => Clk_ClockStaticConfig_Type_Rst_Con,
        StaticConfig_ValIn              => Clk_ClockStaticConfigVal_Type_Rst_Con,
                
        -- Status
        StaticStatus_DatOut             => StaticStatusClk_Dat,
        StaticStatus_ValOut             => StaticStatusClk_Val,
        
        -- Timer
        Timer1ms_EvtOut                 => Timer1ms_Evt,
        
        -- Axi        
        AxiWriteAddrValid_ValIn         => AxiMWriteAddrValid_Val(1),  
        AxiWriteAddrReady_RdyOut        => AxiMWriteAddrReady_Rdy(1),   
        AxiWriteAddrAddress_AdrIn       => AxiMWriteAddrAddress_Adr(1),
        AxiWriteAddrProt_DatIn          => AxiMWriteAddrProt_Dat(1),   
                                                               
        AxiWriteDataValid_ValIn         => AxiMWriteDataValid_Val(1),  
        AxiWriteDataReady_RdyOut        => AxiMWriteDataReady_Rdy(1),   
        AxiWriteDataData_DatIn          => AxiMWriteDataData_Dat(1),   
        AxiWriteDataStrobe_DatIn        => AxiMWriteDataStrobe_Dat(1), 
                                                                    
        AxiWriteRespValid_ValOut        => AxiMWriteRespValid_Val(1),   
        AxiWriteRespReady_RdyIn         => AxiMWriteRespReady_Rdy(1),  
        AxiWriteRespResponse_DatOut     => AxiMWriteRespResponse_Dat(1),
                                                                 
        AxiReadAddrValid_ValIn          => AxiMReadAddrValid_Val(1),   
        AxiReadAddrReady_RdyOut         => AxiMReadAddrReady_Rdy(1),    
        AxiReadAddrAddress_AdrIn        => AxiMReadAddrAddress_Adr(1), 
        AxiReadAddrProt_DatIn           => AxiMReadAddrProt_Dat(1),    
                                                                   
        AxiReadDataValid_ValOut         => AxiMReadDataValid_Val(1),    
        AxiReadDataReady_RdyIn          => AxiMReadDataReady_Rdy(1),   
        AxiReadDataResponse_DatOut      => AxiMReadDataResponse_Dat(1), 
        AxiReadDataData_DatOut          => AxiMReadDataData_Dat(1),     
        
        -- In Sync Output
        InSync_DatOut                   => InSync_Dat,
                                        
        -- Time Output                  
        ClockTime_DatOut                => ClockTime_Dat,
        ClockTime_ValOut                => ClockTime_Val,
                        
        -- Time Adjustment Input        
        TimeAdjustmentPtp_DatIn         => TimeAdjustmentPtp_Dat,
        TimeAdjustmentPtp_ValIn         => TimeAdjustmentPtp_Val,
                
        -- Offset Adjustment Input        
        OffsetAdjustmentPtp_DatIn       => OffsetAdjustmentPtp_Dat,
        OffsetAdjustmentPtp_ValIn       => OffsetAdjustmentPtp_Val,
                
        -- Offset Adjustment Output        
        OffsetAdjustment_DatOut         => OffsetAdjustment_Dat,
        OffsetAdjustment_ValOut         => OffsetAdjustment_Val,
                    
        -- Drift Adjustment Input        
        DriftAdjustmentPtp_DatIn        => DriftAdjustmentPtp_Dat,
        DriftAdjustmentPtp_ValIn        => DriftAdjustmentPtp_Val,
        
        -- Drift Adjustment Output        
        DriftAdjustment_DatOut          => DriftAdjustment_Dat,
        DriftAdjustment_ValOut          => DriftAdjustment_Val   
     );
              

    SignalGenerator_Inst : entity ClkLib.Clk_SignalGenerator
    generic map(
        StaticConfig_Gen                => false,
        ClockClkPeriodNanosecond_Gen    => ClkPeriodNanosecond_Con,
        CableDelay_Gen                  => true,
        OutputDelayNanosecond_Gen       => 0,    
        OutputPolarity_Gen              => true, -- TODO       
        AxiAddressRangeLow_Gen          => Configs_Con(3).AddressRangeLow,
        AxiAddressRangeHigh_Gen         => Configs_Con(3).AddressRangeHigh,
        
        Sim_Gen                         => false
    )
    port map (
        -- System
        SysClk_ClkIn                    => SysClk_Clk,
        SysRstN_RstIn                   => SysRstN_Rst,
        
        -- Config
        StaticConfig_DatIn              => Clk_SignalGeneratorStaticConfig_Type_Rst_Con,
        StaticConfig_ValIn              => Clk_SignalGeneratorStaticConfigVal_Type_Rst_Con,
        
        -- Time Input
        ClockTime_DatIn                 => ClockTime_Dat,
        ClockTime_ValIn                 => ClockTime_Val,
        
        -- Axi        
        AxiWriteAddrValid_ValIn         => AxiMWriteAddrValid_Val(2),  
        AxiWriteAddrReady_RdyOut        => AxiMWriteAddrReady_Rdy(2),   
        AxiWriteAddrAddress_AdrIn       => AxiMWriteAddrAddress_Adr(2),
        AxiWriteAddrProt_DatIn          => AxiMWriteAddrProt_Dat(2),   
                                                               
        AxiWriteDataValid_ValIn         => AxiMWriteDataValid_Val(2),  
        AxiWriteDataReady_RdyOut        => AxiMWriteDataReady_Rdy(2),   
        AxiWriteDataData_DatIn          => AxiMWriteDataData_Dat(2),   
        AxiWriteDataStrobe_DatIn        => AxiMWriteDataStrobe_Dat(2), 
                                                                    
        AxiWriteRespValid_ValOut        => AxiMWriteRespValid_Val(2),   
        AxiWriteRespReady_RdyIn         => AxiMWriteRespReady_Rdy(2),  
        AxiWriteRespResponse_DatOut     => AxiMWriteRespResponse_Dat(2),
                                                                 
        AxiReadAddrValid_ValIn          => AxiMReadAddrValid_Val(2),   
        AxiReadAddrReady_RdyOut         => AxiMReadAddrReady_Rdy(2),    
        AxiReadAddrAddress_AdrIn        => AxiMReadAddrAddress_Adr(2), 
        AxiReadAddrProt_DatIn           => AxiMReadAddrProt_Dat(2),    
                                                                   
        AxiReadDataValid_ValOut         => AxiMReadDataValid_Val(2),    
        AxiReadDataReady_RdyIn          => AxiMReadDataReady_Rdy(2),   
        AxiReadDataResponse_DatOut      => AxiMReadDataResponse_Dat(2), 
        AxiReadDataData_DatOut          => AxiMReadDataData_Dat(2),     

        -- Signal Output
        SignalGenerator_EvtOut          => SignalGenerator_Evt,
        
        -- Interrupt Output
        Irq_EvtOut                      => Irq_Evt    
    );
      
    Tsn_Inst : entity RedLib.Red_TsnEndNodeAxi 
    generic map (
        PrioritySupport_Gen             => true,
        NrOfPriorities_Gen              => 3,
        PhaseSupport_Gen                => true,
        PhasePortSupport_Gen            => false,
        PhaseInSupport_Gen              => false,
        CreditSupport_Gen               => false,
        CycleSupport_Gen                => false,
        PreemptionSupport_Gen           => false,
        PreemptionVerifySupport_Gen     => false,
        PreemptionHoldRelease_Gen       => false,
        MaxCyleDurationNanoseconds_Gen  => 1000000,
        MaxDataSizeSupport_Gen          => false, 
        PortStatusSupport_Gen           => true, 
        SimpleScheduler_Gen             => false,
        ExtAxisInSupport_Gen            => ExtPortTsnApp_Gen, 
        ExtAxisOutSupport_Gen           => ExtPortTsnApp_Gen, 
        ExtPortSupport_Gen              => ExtPortForward_Gen,
        UntaggerSupport_Gen             => false,    
        DstMacCheck_Gen                 => false,
        StaticConfig_Gen                => false,
        LinkSpeedSupport_Gen            => 100,
        ClockClkPeriodNanosecond_Gen    => ClkPeriodNanosecond_Con,
        PtpPortSupport_Gen              => true,
        PtpDefaultProfileSupport_Gen    => false,
        PtpUtilityProfileSupport_Gen    => false,
        HighResSupport_Gen              => false,
        PtpSlaveOnly_Gen                => true,
        PtpMasterOnly_Gen               => false,
        HighResFreqMultiply_Gen         => 5, --250MHz
        RxDelayNanosecond10_Gen         => 4000, -- estimates
        RxDelayNanosecond100_Gen        => 410,              
        TxDelayNanosecond10_Gen         => 1400, -- estimates
        TxDelayNanosecond100_Gen        => 110,   
        AxiAddressRangeLow_Gen          => Configs_Con(0).AddressRangeLow,
        AxiAddressRangeHigh_Gen         => Configs_Con(0).AddressRangeHigh,
        
        Sim_Gen                         => false
    )
    port map (
        -- System
        SysClk_ClkIn                    => SysClk_Clk, 
        SysRstN_RstIn                   => SysRstN_Rst,

        -- Config
        StaticConfigTsn_DatIn           => Red_TsnStaticConfig_Type_Rst_Con,
        StaticConfigTsn_ValIn           => Red_TsnStaticConfigVal_Type_Rst_Con,
        
        -- Status
        StaticStatusTsn_DatOut          => StaticStatusTsn_Dat,
        StaticStatusTsn_ValOut          => StaticStatusTsn_Val,
        StaticStatusPtpOc_DatOut        => StaticStatusPtpOc_Dat,
        StaticStatusPtpOc_ValOut        => StaticStatusPtpOc_Val,
        StaticStatusPtpTc_DatOut        => StaticStatusPtpTc_Dat,
        StaticStatusPtpTc_ValOut        => StaticStatusPtpTc_Val,

        -- Adjustment Input        
        DriftCountAdjustment_DatIn      => StaticStatusClk_Dat.DriftCountAdjustment,
        
        -- Timer
        Timer1ms_EvtIn                  => Timer1ms_Evt,

        -- Time Input   
        ClockTime_DatIn                 => ClockTime_Dat,
        ClockTime_ValIn                 => ClockTime_Val,
                
        -- Link Input
        Link_DatIn                      => '1',
        
        -- Mii Clk Input               
        MiiRxClk_ClkIn                  => Port1MiiRxClk_Clk,
        MiiRxRstN_RstIn                 => Port1MiiRxRstN_Rst,
                                        
        -- Mii Clk Input                
        MiiTxClk_ClkIn                  => Port1MiiTxClk_ClkIn,
        MiiTxRstN_RstIn                 => Port1MiiTxRstN_Rst,

        -- Mii Output                   
        MiiTxEn_EnaOut                  => Port1MiiTxEn_EnaOut,
        MiiTxErr_ErrOut                 => open,
        MiiTxData_DatOut                => Port1MiiTxData_DatOut,
                                        
        -- Mii Input                    
        MiiRxDv_EnaIn                   => Port1MiiRxDv_EnaIn,
        MiiRxErr_ErrIn                  => '0', 
        MiiRxData_DatIn                 => Port1MiiRxData_DatIn,
                                        
        MiiCol_DatIn                    => Port1MiiCol_DatIn,
        MiiCrs_DatIn                    => Port1MiiRxDv_EnaIn,
                                         
        -- Mii Output                   
        MiiRxDv_EnaOut                  => PortXMiiRxDv_Ena, 
        MiiRxErr_ErrOut                 => PortXMiiRxErr_Err,
        MiiRxData_DatOut                => PortXMiiRxData_Dat,
                                               
        MiiCol_DatOut                   => PortXMiiCol_Dat,  
        MiiCrs_DatOut                   => PortXMiiCrs_Dat,  
                                               
        -- Mii Input                           
        MiiTxEn_EnaIn                   => PortXMiiTxEn_Ena,      
        MiiTxErr_ErrIn                  => PortXMiiTxErr_Err, 
        MiiTxData_DatIn                 => PortXMiiTxData_Dat,
        
        -- Axi
        AxiWriteAddrValid_ValIn         => AxiMWriteAddrValid_Val(0),  
        AxiWriteAddrReady_RdyOut        => AxiMWriteAddrReady_Rdy(0),   
        AxiWriteAddrAddress_AdrIn       => AxiMWriteAddrAddress_Adr(0),
        AxiWriteAddrProt_DatIn          => AxiMWriteAddrProt_Dat(0),   
                                                               
        AxiWriteDataValid_ValIn         => AxiMWriteDataValid_Val(0),  
        AxiWriteDataReady_RdyOut        => AxiMWriteDataReady_Rdy(0),   
        AxiWriteDataData_DatIn          => AxiMWriteDataData_Dat(0),   
        AxiWriteDataStrobe_DatIn        => AxiMWriteDataStrobe_Dat(0), 
                                                                    
        AxiWriteRespValid_ValOut        => AxiMWriteRespValid_Val(0),   
        AxiWriteRespReady_RdyIn         => AxiMWriteRespReady_Rdy(0),  
        AxiWriteRespResponse_DatOut     => AxiMWriteRespResponse_Dat(0),
                                                                 
        AxiReadAddrValid_ValIn          => AxiMReadAddrValid_Val(0),   
        AxiReadAddrReady_RdyOut         => AxiMReadAddrReady_Rdy(0),    
        AxiReadAddrAddress_AdrIn        => AxiMReadAddrAddress_Adr(0), 
        AxiReadAddrProt_DatIn           => AxiMReadAddrProt_Dat(0),    
                                                                   
        AxiReadDataValid_ValOut         => AxiMReadDataValid_Val(0),    
        AxiReadDataReady_RdyIn          => AxiMReadDataReady_Rdy(0),   
        AxiReadDataResponse_DatOut      => AxiMReadDataResponse_Dat(0), 
        AxiReadDataData_DatOut          => AxiMReadDataData_Dat(0),
        
        -- Time Adjustment Output        
        TimeAdjustment_DatOut           => TimeAdjustmentPtp_Dat,
        TimeAdjustment_ValOut           => TimeAdjustmentPtp_Val,
                                        
        -- Offset Adjustment Output        
        OffsetAdjustment_DatOut         => OffsetAdjustmentPtp_Dat,
        OffsetAdjustment_ValOut         => OffsetAdjustmentPtp_Val,
                                        
        -- Drift Adjustment Output      
        DriftAdjustment_DatOut          => DriftAdjustmentPtp_Dat,
        DriftAdjustment_ValOut          => DriftAdjustmentPtp_Val,    

        -- Offset Adjustment Input        
        OffsetAdjustment_DatIn          => OffsetAdjustment_Dat,
        OffsetAdjustment_ValIn          => OffsetAdjustment_Val,
                                        
        -- Drift Adjustment Input         
        DriftAdjustment_DatIn           => DriftAdjustment_Dat,
        DriftAdjustment_ValIn           => DriftAdjustment_Val 
    );                
                      
    VlanExt_Dat <= (others => Red_Vlan_Type_Rst_Con);
    VlanExt_Val <= (others => '0');
    

end architecture NiosIITop_Arch;                                             