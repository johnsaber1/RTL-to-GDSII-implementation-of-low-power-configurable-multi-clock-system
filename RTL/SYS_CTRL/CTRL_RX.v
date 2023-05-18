
module CTRL_RX #(parameter WIDTH = 8, ADDR = 4 )

(
input    wire                 CLK,
input    wire                 RST,
input    wire   [WIDTH-1:0]   RF_RdData,
input    wire                 RF_RdData_VLD,
input    wire   [WIDTH*2-1:0] ALU_OUT,
input    wire                 ALU_OUT_VLD, 
input    wire   [WIDTH-1:0]   UART_RX_DATA, 
input    wire                 UART_RX_VLD,
output   reg                  ALU_EN,
output   reg    [3:0]         ALU_FUN,  
output   reg                  CLKG_EN, 
output   reg                  CLKDIV_EN,
output   reg                  RF_WrEn,
output   reg                  RF_RdEn,
output   reg   [ADDR-1:0]     RF_Address,
output   reg   [WIDTH-1:0]    RF_WrData,
output   reg                  UART_RF_SEND,
output   reg                  UART_ALU_SEND,
output   reg   [WIDTH-1:0]    UART_SEND_RF_DATA,
output   reg   [WIDTH*2-1:0]  UART_SEND_ALU_DATA  	
);


// state encoding
localparam  [3:0]      IDLE         = 4'b0000 ,
                       WRITE_CMD_S  = 4'b0001 ,
					   WRITE_ADD_S  = 4'b0010 ,
					   WRITE_DAT_S  = 4'b0011 ,
					   READ_CMD_S   = 4'b0100 ,
					   READ_ADD_S   = 4'b0101 ,
					   READ_WAIT_S  = 4'b0110 ,
					   ALU_WP_OPA_S = 4'b0111 ,
					   ALU_WP_OPB_S = 4'b1000 ,					   
					   ALU_OP_FUN_S = 4'b1001 ,
                       ALU_WAIT_O_S = 4'b1010 ;
					   
localparam  [7:0]      RF_WRITE_CMD  = 8'hAA ,
                       RF_READ_CMD   = 8'hBB ,
					   ALU_W_OP_CMD  = 8'hCC ,
					   ALU_WN_OP_CMD = 8'hDD ;
					   
reg         [3:0]      current_state , 
                       next_state    ;
			
reg         [7:0]      RF_ADDR_REG ;

reg                    RF_ADDR_EN   ,
                       RF_RD_STORE  ,
                       ALU_DAT_STOR ;					   


				   
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
  case(current_state)
  IDLE   	: begin
				if(UART_RX_VLD)
			      begin
					case(UART_RX_DATA)  // command
					RF_WRITE_CMD : begin
									next_state = WRITE_ADD_S ;				
								   end
					RF_READ_CMD  : begin
									next_state = READ_ADD_S ;				
								   end
					ALU_W_OP_CMD : begin
									next_state = ALU_WP_OPA_S ;				
								   end
					ALU_WN_OP_CMD: begin
			                        next_state = ALU_OP_FUN_S ;				
								   end							   
					default      : begin
									next_state = IDLE ;				
								   end
					endcase	
				  end
				else
				  begin
					next_state = IDLE ;
				  end
				end			  							  			
  WRITE_ADD_S : begin
				 if(UART_RX_VLD)
			       begin
			        next_state = WRITE_DAT_S ; 				
                   end
			     else
			       begin
			        next_state = WRITE_ADD_S ; 			
                   end			  
                end
  WRITE_DAT_S : begin
				 if(UART_RX_VLD)
			       begin
			        next_state = IDLE ; 				
                   end
			     else
			       begin
			        next_state = WRITE_DAT_S ; 			
                   end			  
                end  		  
  READ_ADD_S  : begin
				 if(UART_RX_VLD)
			       begin
			        next_state = READ_WAIT_S ; 				
                   end
			     else
			       begin
			        next_state = READ_ADD_S ; 			
                   end			  
                end
  READ_WAIT_S : begin
				 if(RF_RdData_VLD)
			       begin
			        next_state = IDLE ; 				
                   end
			     else
			       begin
			        next_state = READ_WAIT_S ; 			
                   end			  
                end			
  ALU_WP_OPA_S: begin
				 if(UART_RX_VLD)
			       begin
			        next_state = ALU_WP_OPB_S ; 				
                   end
			     else
			       begin
			        next_state = ALU_WP_OPA_S ; 			
                   end			  
                end	
  ALU_WP_OPB_S: begin
				 if(UART_RX_VLD)
			       begin
			        next_state = ALU_OP_FUN_S ; 				
                   end
			     else
			       begin
			        next_state = ALU_WP_OPB_S ; 			
                   end			  
                end	
  ALU_OP_FUN_S: begin
				 if(UART_RX_VLD)
			       begin
			        next_state = ALU_WAIT_O_S ; 				
                   end
			     else
			       begin
			        next_state = ALU_OP_FUN_S ; 			
                   end			  
                end	
  ALU_WAIT_O_S: begin
				 if(ALU_OUT_VLD)
			       begin
			        next_state = IDLE ; 				
                   end
			     else
			       begin
			        next_state = ALU_WAIT_O_S ; 			
                   end			  
                end					
  default     : begin
			      next_state = IDLE ; 
                end	
  endcase                 	   
 end 

// output logic
always @ (*)
 begin
   ALU_EN     = 1'b0 ;
   ALU_FUN    = 4'b0 ;  
   CLKG_EN    = 1'b0 ; 
   CLKDIV_EN  = 1'b1 ;
   RF_WrEn    = 1'b0 ;
   RF_RdEn    = 1'b0 ;
   RF_Address =  'b0 ;
   RF_WrData  =  'b0 ;
   RF_ADDR_EN = 1'b0 ;
   UART_RF_SEND  = 1'b0 ; 
   UART_ALU_SEND = 1'b0 ;
   RF_RD_STORE   = 1'b0 ;
   ALU_DAT_STOR  = 1'b0 ;   
  case(current_state)
  IDLE   	  : begin
				  ALU_EN     = 1'b0 ;
				  ALU_FUN    = 4'b0 ;  
				  CLKG_EN    = 1'b0 ; 
				  CLKDIV_EN  = 1'b1 ;
				  RF_WrEn    = 1'b0 ;
				  RF_RdEn    = 1'b0 ;
				  RF_Address =  'b0 ;
				  RF_WrData  =  'b0 ;
				end			  							  			
  WRITE_ADD_S : begin
				 if(UART_RX_VLD)
			       begin
			        RF_ADDR_EN = 1'b1 ; 				
                   end
			     else
			       begin
			        RF_ADDR_EN = 1'b0 ; 			
                   end					   	  
                end
  WRITE_DAT_S : begin
				 if(UART_RX_VLD)
			       begin
				    RF_WrEn    = 1'b1         ;
					RF_Address = RF_ADDR_REG  ;
					RF_WrData  = UART_RX_DATA ;
                   end
			     else
			       begin
				    RF_WrEn    = 1'b0         ;
					RF_Address = RF_ADDR_REG  ;
					RF_WrData  = UART_RX_DATA ; 			
                   end					   	  
                end
  READ_ADD_S  : begin
				 if(UART_RX_VLD)
			       begin
			        RF_ADDR_EN = 1'b1 ; 				
                   end
			     else
			       begin
			        RF_ADDR_EN = 1'b0 ; 			
                   end					   	  
                end
  READ_WAIT_S : begin
				  RF_RdEn    = 1'b1         ;
				  RF_Address = RF_ADDR_REG  ;
				  if(RF_RdData_VLD)
			       begin
			        UART_RF_SEND = 1'b1 ; 
                    RF_RD_STORE  = 1'b1 ;					
                   end
			      else
			       begin
			        UART_RF_SEND = 1'b0 ;	
                    RF_RD_STORE  = 1'b0 ;						
                   end					  
                end		
  ALU_WP_OPA_S: begin
				 if(UART_RX_VLD)
				   begin
				    RF_WrEn    = 1'b1         ;
					RF_Address = 'b00         ;
					RF_WrData  = UART_RX_DATA ;
				   end	
			     else
			       begin
				    RF_WrEn    = 1'b0         ;
					RF_Address = 'b00         ;
					RF_WrData  = UART_RX_DATA ; 			
                   end			  
                end	
  ALU_WP_OPB_S: begin
				 if(UART_RX_VLD)
				  begin
				    RF_WrEn    = 1'b1         ;
					RF_Address = 'b01         ;
					RF_WrData  = UART_RX_DATA ;
				  end	
			     else
			       begin
				    RF_WrEn    = 1'b0         ;
					RF_Address = 'b01         ;
					RF_WrData  = UART_RX_DATA ; 			
                   end			  
                end	
  ALU_OP_FUN_S: begin
				 CLKG_EN = 1'b1 ;  
				 if(UART_RX_VLD)
			       begin
                     ALU_EN  = 1'b1 ;
                     ALU_FUN = UART_RX_DATA ; 			
                   end
			     else
			       begin
                     ALU_EN  = 1'b0 ;
                     ALU_FUN = UART_RX_DATA ; 				
                   end			  
                end	
  ALU_WAIT_O_S: begin
				 CLKG_EN = 1'b1 ;   
				 if(ALU_OUT_VLD)
			       begin
			        UART_ALU_SEND = 1'b1 ; 
                    ALU_DAT_STOR  = 1'b1 ;							
                   end
			      else
			       begin
			        UART_ALU_SEND = 1'b0 ;
                    ALU_DAT_STOR  = 1'b0 ;							
                   end
                end				   
  default     : begin
		    ALU_EN     = 1'b0 ;
		    ALU_FUN    = 4'b0 ;  
		    CLKG_EN    = 1'b0 ; 
	            CLKDIV_EN  = 1'b1 ;
		    RF_WrEn    = 1'b0 ;
		    RF_RdEn    = 1'b0 ;
		    RF_Address =  'b0 ;
		    RF_WrData  =  'b0 ;
                end	
  endcase                 	   
 end 
							  
// **************** storing RF Address **************** //
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    RF_ADDR_REG <= 8'b0 ;
   end
  else
   begin
    if (RF_ADDR_EN)
	 begin	
      RF_ADDR_REG <= UART_RX_DATA ;
	 end 
   end
 end
 
// **************** storing RF READ Data **************** //
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    UART_SEND_RF_DATA <= 8'b0 ;
   end
  else
   begin
    if (RF_RD_STORE)
	 begin
      UART_SEND_RF_DATA <= RF_RdData ;
	 end 
   end
 end
 
// **************** storing ALU Result **************** //
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    UART_SEND_ALU_DATA <= 'b0 ;
   end
  else
   begin
    if (ALU_DAT_STOR)
	 begin
      UART_SEND_ALU_DATA <= ALU_OUT ;
	 end 
   end
 end

endmodule
