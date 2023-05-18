
module SYS_CTRL #(parameter WIDTH = 8, ADDR = 4 )

(
input    wire                 CLK,
input    wire                 RST,
input    wire   [WIDTH-1:0]   RF_RdData,
input    wire                 RF_RdData_VLD,
output   wire                 RF_WrEn,
output   wire                 RF_RdEn,
output   wire   [ADDR-1:0]    RF_Address,
output   wire   [WIDTH-1:0]   RF_WrData,
input    wire   [WIDTH*2-1:0] ALU_OUT,
input    wire                 ALU_OUT_VLD, 
output   wire                 ALU_EN,
output   wire   [3:0]         ALU_FUN,  
output   wire                 CLKG_EN, 
output   wire                 CLKDIV_EN, 
input    wire   [WIDTH-1:0]   UART_RX_DATA, 
input    wire                 UART_RX_VLD,
input    wire                 UART_TX_Busy,
output   wire   [WIDTH-1:0]   UART_TX_DATA, 
output   wire                 UART_TX_VLD
);

wire       [WIDTH*2-1:0]      UART_SEND_ALU_DATA ;
wire       [WIDTH-1:0]        UART_SEND_RF_DATA ;
wire                          UART_RF_SEND ;
wire                          UART_ALU_SEND ;


CTRL_RX U0_CTRL_RX (
.CLK(CLK),
.RST(RST),
.RF_RdData(RF_RdData),
.RF_RdData_VLD(RF_RdData_VLD),
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD), 
.UART_RX_DATA(UART_RX_DATA), 
.UART_RX_VLD(UART_RX_VLD),
.ALU_EN(ALU_EN),
.ALU_FUN(ALU_FUN),  
.CLKG_EN(CLKG_EN), 
.CLKDIV_EN(CLKDIV_EN),
.RF_WrEn(RF_WrEn),
.RF_RdEn(RF_RdEn),
.RF_Address(RF_Address),
.RF_WrData(RF_WrData),
.UART_RF_SEND(UART_RF_SEND),
.UART_ALU_SEND(UART_ALU_SEND),
.UART_SEND_RF_DATA(UART_SEND_RF_DATA),
.UART_SEND_ALU_DATA(UART_SEND_ALU_DATA)
);


CTRL_TX U0_CTRL_TX (
.CLK(CLK),
.RST(RST),
.UART_RF_SEND(UART_RF_SEND),
.UART_ALU_SEND(UART_ALU_SEND),
.UART_SEND_ALU_DATA(UART_SEND_ALU_DATA),
.UART_SEND_RF_DATA(UART_SEND_RF_DATA),
.UART_TX_Busy(UART_TX_Busy),
.UART_TX_DATA(UART_TX_DATA),
.UART_TX_VLD(UART_TX_VLD)
);


endmodule