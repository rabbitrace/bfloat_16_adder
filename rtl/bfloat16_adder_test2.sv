module bfloat16_adder (output logic [15:0] sum,
			output logic ready, input logic [15:0] a, b,
			input logic clock, nreset);
			
//	enum{IDLE,EXTRACTA,EXTRACTB,COMPARE,ADD,RESTOR,FINISH} state; 
	enum{IDLE,EXTRACTA,COMPARE,ADD,RESTOR,FINISH} state; 
	
	logic [6:0] sum_mantissa;
	
	logic[7:0] a_exponent,b_exponent,sum_exponent;
	
	logic a_signal,b_signal,sum_error;
	
	logic[9:0]a_combination,b_combination,sum_combination;//{signal，count out,value 1,mantissa}
	
	
	
//	function one_locaion(input logic [7:0]exponent,input logic[9:0]combination, output logic[9:0] final_combination,output logic [7:0]final_exponent);
//		genvar i;
//		generate for(i = 0 ;i<= 8 ; i ++)
//			begin
//				if(combination[8] == 1'b1)
//					begin
//						final_exponent = exponent +1'b1;
//					   7final_combination = {combination[]}
//					end
//			end
//		endgenerate 
	
//	endfunction
	
	
	always_ff@(posedge clock,negedge nreset)
		if(!nreset)begin
			state <= IDLE;
			sum = '0;
		end
		else 
			case(state)
				IDLE: 
					state <= EXTRACTA;
					
				EXTRACTA:
					begin
						if(((a[14:7] ==8'b1111_1111) && (a[6:0] != 7'd0)) || ((a[14:7] ==8'b1111_1111) && (a[6:0] == 7'd0)))
							begin
								state <= FINISH ;
								sum_error <= 1'b1;
							end
						else 
							sum_error <= 1'b0;
							a_signal <= a[15];
							a_exponent <= a[14:7];
							a_combination <= {a[15],1'b0,1'b1,a[6:0]};
							b_signal <= b[15];
							b_exponent <= b[14:7];
							b_combination <= {b[15],1'b0,1'b1,b[6:0]};
							state <= COMPARE ;
							
					end
//				EXTRACTB:
//					begin
//						b_signal <= b[15];
//						b_exponent <= b[14:7];
//						b_combination <= {b[15],1'b0,1'b1,b[6:0]};
//						state <= COMPARE ;
//					end
				COMPARE:
					begin
						if(a_exponent > b_exponent) 
							if((a_exponent -b_exponent)>= 4'd8 ) // huge diffenence 
								begin
									sum_exponent <= a_exponent;
									sum_combination <= a_combination ;
									sum_mantissa <= a_combination[6:0];
									state <= FINISH ;
								end
							else 
								begin
									b_exponent <= b_exponent + 1'b1;
									b_combination[7:0] ={1'b0,b_combination[7:1]} ;
									state <= COMPARE; // untile a_exponent = b_exponent;
								end
						else if (b_exponent > a_exponent)
							begin
								if((b_exponent - a_exponent)>= 4'd8 )
									begin
										sum_exponent <= b_exponent;
										sum_combination <= b_combination ;
										sum_mantissa <= b_combination[6:0];
										state <= FINISH ;
									end
								else 
									begin
										a_exponent <= a_exponent + 1'b1;
										a_combination[7:0] ={1'b0,a_combination[7:1]} ;
										
										state <= COMPARE;
									end
							end
						else if (a_exponent == b_exponent)
								begin
									sum_exponent <= a_exponent;
									state <= ADD;
								end
								
					end
				  ADD:
					begin
						if(a_signal == b_signal)
							begin
								sum_combination[8:0] <= a_combination[8:0] + b_combination[8:0];
								sum_combination[9] <= a_signal ;
								
							end
						else if ((a_signal!= b_signal) && (a_combination[8:0] >b_combination[8:0]))
							begin
								sum_combination[8:0] <= a_combination[8:0] - b_combination[8:0];
								sum_combination[9] <= a_signal ;
							end
						else if ((a_signal!= b_signal) && (b_combination[8:0] > a_combination[8:0] ))
							begin
								sum_combination[8:0] = b_combination[8:0] - a_combination[8:0] ;
								sum_combination[9] <= b_signal ;
							end
						state <= RESTOR;
					end
							
				
				RESTOR :
					begin
						if(sum_combination[8] == 1'b1) // count_out is 1
							begin
							sum_exponent <= sum_exponent + 1'b1 ;
							sum_mantissa <= sum_combination[7:1]; // abandon the final bit
							state <= FINISH ;
							end
						else if (sum_combination[7] == 1'b0)
							begin
								sum_exponent <= sum_exponent - 1'b1;
								sum_combination[8:0] <={sum_combination[7:0],1'b0};
								state <= RESTOR ; // until find the first one
							end
						else if (sum_combination[7] == 1'b1)
							begin
								sum_mantissa <=  sum_combination[6:0]; //abandon the value 1
								state <= FINISH;
							end
							
					end
				 FINISH :
					begin
						if(sum_error == 1'b1)
							sum <= 'x ;
						else
							sum <= {sum_combination[9],sum_exponent,sum_mantissa}; // signal , e, mantissa
						
						state <=  IDLE ;
					end
					default:  state <= IDLE ;
			
				
			endcase 
	
	always_comb
		begin
			if(state == IDLE)
				ready = 1'b1;
			else 
				ready = 1'b0;
		end
		
			
//				EXTRACT:
//					begin
//						a_signal <= a[15];
//						b_signal <= b[15];
//						a_exponent <= a[14:7];
//						b_exponent <= b[14:7];
//						a_combination <= {a[15],1'b0,1'b1,a[6:0]};
//						b_combination <= {b[15],1'b0,1'b1,b[6:0]};
//					abnormal
//					if(a[14:0] == 15b'0) // if a is 0,sum = b ;
//						begin
//							sum_combination <= b_combination;
//							sum_exponent <= b_exponent;
//							state <= FINISH;
//						end
//					else if(b[14:0] == 15b'0) //if b is 0 ,sum = a ; 
//						begin
//							sum_combination <= a_combination;
//							sum_exponent <= b_exponent;
//							state <= FINISH;
//						end
//					else 
//						state <= COMPARE;
//					end
			
//	bit m_dirction[1:0];
//	
//	bit [15:0]a_copy;
//	bit [15:0]b_copy;
//	
//	int exponent_a;
//	int exponent_b;
//	
////	logic [1:0] exponent_signal ;//exponent_signal[1] a \ exponent_signal[0] b
//	logic[255:0] value_a;
//	logic[255:0] value_b;
//	
//	logic[255:0] value_a_true;
//	logic[255:0] value_b_true;
//	
//	logic sum_sign;
//	logic [6:0]sum_value;
//	logic [7:0]sum_exponent;
//	genvar i;
//	
//	always_ff@(posedge clock,negedge nreset)
//		begin
//			if(!nreset)
//				begin
//					a_copy <= '0;
//					b_copy <= '0;
//
//				end
//			
//		end
//	
//	always_comb
//		begin
//			value_a = '0;
//			value_b = '0;
//			value_a[255] =a[15]; 	//a_signal_0/1
//			value_b[255] =b[15]; 	//b_signal_0/1
//			
//			if(a[14:7] >= 7'd127 ) 
//				begin
//					exponent_a = a[14:7] - 7'd127 ; //extract exponent data 
//					value_a[127:0] = {1'b1,a[6:0]}; //make 127is 1
//					if(a[15] == 1'b1)
//						value_a_true[127:120] = (~value_a[127:120]) +1 ;
//						
//				end
//
//			else 
//				begin
//					exponent_a = 7'd127 - a[14:7];
//					value_a[127:0] = {1'b1,a[6:0]} >>  exponent_a;
//				end
//			
//			
//	
//			if(b[14:7] >= 7'd127 )
//				begin
//					exponent_b = b[14:7] - 7'd127 ;
//					value_b[127:0] = {1'b1,b[6:0]} << exponent_b;
//				end
//
//				
//			else 
//				begin
//					exponent_b = 7'd127 - b[14:7];
//					value_b[127:0] = {1'b1,b[6:0]} >> exponent_b;
//				end
//			
//			
//				
//			
//		end
//	
//	always_ff@(posedge clock, negedge nreset)
//		begin
//			if(!nreset)
//				begin
//					value_a_true <= '0;
//					value_b_true <= '0;
//				end
//			else if(a[15] == 1'b1)
//				begin
//					value_a_true <= {a[15],((~value_a[254:0])+1)};
//				end
//			else if(b[15] == 1'b1)
//				begin
//					value_b_true <= {b[15],((~value_b[254:0])+1)};					
//				end
//		end
		
	
			
endmodule 