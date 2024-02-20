module bfloat16_adder_test (output logic [15:0] sum,
			output logic ready, input logic [15:0] a, b,
			input logic clock, nreset);
			
//	enum{IDLE,EXTRACTA,EXTRACTB,COMPARE,ADD,RESTOR,FINISH} state; 
	enum{IDLE,EXTRACTA,COMPARE,ADD,RESTOR,FINISH} state; 
	
	logic [6:0] sum_mantissa;
	
	logic[7:0] a_exponent,b_exponent,sum_exponent;
	
	logic a_signal,b_signal,sum_error,sum_siganl,sum_zero;
	
	logic[256:0]a_combination,b_combination,sum_combination;//count out,value 1,mantissa}
	
	
	always_ff@(posedge clock,negedge nreset)
		if(!nreset)begin
			state <= IDLE;
			sum = '0;
		end
		else 
			case(state)
				IDLE: 
					begin
						state <= EXTRACTA;
						a_combination <= '0;
						b_combination <= '0;
					end
				EXTRACTA:
					begin
//						if(((a[14:7] ==8'b1111_1111) && (a[6:0] != 7'd0)) || ((a[14:7] ==8'b1111_1111) && (a[6:0] == 7'd0)))
//							begin
//								sum_error <= 1'b1;
//								state <= FINISH ;
//
//							end
//						else 
						if(a == '0)
							begin
								{sum_siganl,sum_exponent,sum_mantissa}= b;
								state <= FINISH ;
							end
						else if(b == '0)
							begin
								{sum_siganl,sum_exponent,sum_mantissa}= a;
								state <= FINISH ;
							end
						else
							begin
								a_signal <= a[15];
								a_exponent <= a[14:7];
								a_combination[256:248] <= {1'b0,1'b1,a[6:0]};
								b_signal <= b[15];
								b_exponent <= b[14:7];
								b_combination[256:248] <= {1'b0,1'b1,b[6:0]};
								state <= COMPARE ;
							end

							
					end
				COMPARE:
					begin
						if(a_exponent > b_exponent) 
								begin
									b_exponent <= b_exponent + 1'b1;
									b_combination ={1'b0,b_combination[256:1]} ;
									state <= COMPARE; // untile a_exponent = b_exponent;
								end
						else if (b_exponent > a_exponent) 
								begin
									a_exponent <= a_exponent + 1'b1;
									a_combination ={1'b0,a_combination[256:1]} ;
									state <= COMPARE;
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
								sum_combination <= a_combination + b_combination;
								sum_siganl <= a_signal ;
							end
						else if ((a_signal!= b_signal) && (a_combination >b_combination))
							begin
								sum_combination <= a_combination - b_combination;
								sum_siganl <= a_signal ;
							end
						else if ((a_signal!= b_signal) && (b_combination > a_combination ))
							begin
								sum_combination = b_combination - a_combination ;
								sum_siganl <= b_signal ;
							end
						else if ((a_signal!= b_signal) && (a_combination =b_combination))
							begin
								sum_combination = '0 ;
								sum_exponent = '0;
								sum_siganl <= a_signal ;
								state <= FINISH;
							end
							
						state <= RESTOR;
					end
							
				
				RESTOR :
					begin
						if(sum_combination == '0)begin
//							sum_error <= 1'b1;
							sum_mantissa<='0;
							state <= FINISH;
						end
						else if(sum_combination[256] == 1'b1) // count_out is 1
							begin
							sum_exponent <= sum_exponent + 1'b1 ;
							sum_mantissa <= sum_combination[255:249]; // abandon the final bit
							state <= FINISH ;
							end
						else if (sum_combination[255] == 1'b0)
							begin
								sum_exponent <= sum_exponent - 1'b1;
								sum_combination <= {sum_combination[254:0],1'b0};
								state <= RESTOR ; // until find the first one
							end
						else if (sum_combination[255] == 1'b1)
							begin
								sum_mantissa <=  sum_combination[254:248]; //abandon the value 1
								state <= FINISH;
							end
							
					end
				 FINISH :
					begin
						if(sum_error == 1'b1)
							begin
								sum <= 'x ;
								sum_error <= 1'b0;
							end

						else
							sum <= {sum_siganl,sum_exponent,sum_mantissa}; // signal , e, mantissa
						
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
		
			
endmodule 