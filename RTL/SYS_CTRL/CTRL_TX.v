
module CTRL_TX #(parameter WIDTH = 8, ADDR = 4 )

(
input    wire                CLK,
input    wire                RST,
input    wire                UART_RF_SEND,
input    wire  [WIDTH-1:0]   UART_SEND_RF_DATA,
input    wire                UART_ALU_SEND,
input    wire  [WIDTH*2-1:0] UART_SEND_ALU_DATA,
input    wire                UART_TX_Busy,
output   reg   [WIDTH-1:0]   UART_TX_DATA, 
output   reg                 UART_TX_VLD
);


// state encoding
localparam   [2:0]     IDLE             = 3'b000 ,
                       UART_RF_SEND_S   = 3'b001 ,
                       UART_ALU0_SEND_S = 3'b010 ,
                       WAIT_UART_BUST   = 3'b011 ,					   
                       UART_ALU1_SEND_S = 3'b100 ;
					   
reg          [2:0]     current_state , 
                       next_state    ;
					   
//state transiton 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    current_state <= IDLE ;
   end
  else
   begin
    current_state <= next_state ;
   end
 end
 

// next state logic
always @ (*)
 begin
  next_state = IDLE ;
  case(current_state)
  IDLE   	   : begin
				  if(UART_RF_SEND)
			        begin
					 next_state = UART_RF_SEND_S ;
				    end
				  else if (UART_ALU_SEND)
				    begin
					 next_state = UART_ALU0_SEND_S ;
				    end
				  end			  							  			
  UART_RF_SEND_S  : begin
			         if (UART_TX_Busy)  
			           next_state = IDLE ;
                     else	
			           next_state = UART_RF_SEND_S ;					 
                    end	
  UART_ALU0_SEND_S: begin
			         if (UART_TX_Busy)
			           next_state = WAIT_UART_BUST ;
                     else
 			           next_state = UART_ALU0_SEND_S ;						 
                    end
  WAIT_UART_BUST  : begin
			         if (!UART_TX_Busy)
			           next_state = UART_ALU1_SEND_S ;
                     else
 			           next_state = WAIT_UART_BUST ;						 
                    end					
  UART_ALU1_SEND_S: begin
			         if (UART_TX_Busy)  
			           next_state = IDLE ;
                     else	
			           next_state = UART_ALU1_SEND_S ;					 	  
                    end					  
  default     : begin
			      next_state = IDLE ; 
                end	
  endcase                 	   
 end 

// output logic
always @ (*)
 begin
   UART_TX_VLD   = 1'b0 ;
   UART_TX_DATA  = 'b0 ;   	  
  case(current_state)
  IDLE   	      : begin
                      UART_TX_DATA  = 'b0 ; 
                      UART_TX_VLD = 1'b0 ;	
				    end			  							  			
  UART_RF_SEND_S  : begin
                      UART_TX_DATA  = UART_SEND_RF_DATA ; 
                      UART_TX_VLD = 1'b1 ;			   	  
                    end
  UART_ALU0_SEND_S: begin
                      UART_TX_DATA  = UART_SEND_ALU_DATA [WIDTH-1:0] ; 
                      UART_TX_VLD = 1'b1 ;
                    end					  
  WAIT_UART_BUST  : begin
                      UART_TX_DATA  = 'b0 ;   
                      UART_TX_VLD = 1'b0 ;			  
                    end	
  UART_ALU1_SEND_S: begin
                      UART_TX_DATA  = UART_SEND_ALU_DATA [WIDTH*2-1:WIDTH] ; 
                      UART_TX_VLD = 1'b1 ;			  
                    end	
  default     : begin
                  UART_TX_VLD = 1'b0 ;	
                end	
  endcase                 	   
 end 




endmodule
