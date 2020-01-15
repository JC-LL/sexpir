/* Machine-generated using Migen */
module uart(
	input sys_clk,
	input sys_rst
);

reg [7:0] rx_data = 8'd0;
reg rx_ready;
reg rx_ack = 1'd0;
reg rx_error;
reg [7:0] tx_data = 8'd0;
reg tx_ready = 1'd0;
reg tx_ack;
reg rx = 1'd1;
reg tx = 1'd0;
reg [1:0] rx_counter = 2'd0;
wire rx_strobe;
reg [2:0] rx_bitno = 3'd0;
reg [1:0] tx_counter = 2'd0;
wire tx_strobe;
reg [2:0] tx_bitno = 3'd0;
reg [7:0] tx_latch = 8'd0;
reg [2:0] fsm0_state = 3'd0;
reg [2:0] fsm0_next_state;
reg [1:0] rx_counter_next_value0;
reg rx_counter_next_value_ce0;
reg [7:0] rx_data_next_value1;
reg rx_data_next_value_ce1;
reg [2:0] rx_bitno_next_value2;
reg rx_bitno_next_value_ce2;
reg [1:0] fsm1_state = 2'd0;
reg [1:0] fsm1_next_state;
reg [1:0] tx_counter_t_next_value0;
reg tx_counter_t_next_value_ce0;
reg [7:0] tx_latch_t_next_value1;
reg tx_latch_t_next_value_ce1;
reg tx_f_next_value;
reg tx_f_next_value_ce;
reg [2:0] tx_bitno_t_next_value2;
reg tx_bitno_t_next_value_ce2;

// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign rx_strobe = (rx_counter == 1'd0);
assign tx_strobe = (tx_counter == 1'd0);

// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	rx_ready <= 1'd0;
	rx_error <= 1'd0;
	fsm0_next_state <= 3'd0;
	rx_counter_next_value0 <= 2'd0;
	rx_counter_next_value_ce0 <= 1'd0;
	rx_data_next_value1 <= 8'd0;
	rx_data_next_value_ce1 <= 1'd0;
	rx_bitno_next_value2 <= 3'd0;
	rx_bitno_next_value_ce2 <= 1'd0;
	fsm0_next_state <= fsm0_state;
	case (fsm0_state)
		1'd1: begin
			if (rx_strobe) begin
				fsm0_next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (rx_strobe) begin
				rx_data_next_value1 <= {rx, rx_data[7:1]};
				rx_data_next_value_ce1 <= 1'd1;
				rx_bitno_next_value2 <= (rx_bitno + 1'd1);
				rx_bitno_next_value_ce2 <= 1'd1;
				if ((rx_bitno == 3'd7)) begin
					fsm0_next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if (rx_strobe) begin
				if ((~rx)) begin
					fsm0_next_state <= 3'd5;
				end else begin
					fsm0_next_state <= 3'd4;
				end
			end
		end
		3'd4: begin
			rx_ready <= 1'd1;
			if (rx_ack) begin
				fsm0_next_state <= 1'd0;
			end else begin
				if ((~rx)) begin
					fsm0_next_state <= 3'd5;
				end
			end
		end
		3'd5: begin
			rx_error <= 1'd1;
		end
		default: begin
			if ((~rx)) begin
				rx_counter_next_value0 <= 2'd2;
				rx_counter_next_value_ce0 <= 1'd1;
				fsm0_next_state <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end

// synthesis translate_off
reg dummy_d_1;
// synthesis translate_on
always @(*) begin
	tx_ack <= 1'd0;
	fsm1_next_state <= 2'd0;
	tx_counter_t_next_value0 <= 2'd0;
	tx_counter_t_next_value_ce0 <= 1'd0;
	tx_latch_t_next_value1 <= 8'd0;
	tx_latch_t_next_value_ce1 <= 1'd0;
	tx_f_next_value <= 1'd0;
	tx_f_next_value_ce <= 1'd0;
	tx_bitno_t_next_value2 <= 3'd0;
	tx_bitno_t_next_value_ce2 <= 1'd0;
	fsm1_next_state <= fsm1_state;
	case (fsm1_state)
		1'd1: begin
			if (tx_strobe) begin
				tx_f_next_value <= 1'd0;
				tx_f_next_value_ce <= 1'd1;
				fsm1_next_state <= 2'd2;
			end
		end
		2'd2: begin
			if (tx_strobe) begin
				tx_f_next_value <= tx_latch[0];
				tx_f_next_value_ce <= 1'd1;
				tx_latch_t_next_value1 <= {1'd0, tx_latch[7:1]};
				tx_latch_t_next_value_ce1 <= 1'd1;
				tx_bitno_t_next_value2 <= (tx_bitno + 1'd1);
				tx_bitno_t_next_value_ce2 <= 1'd1;
				if ((tx_bitno == 3'd7)) begin
					fsm1_next_state <= 2'd3;
				end
			end
		end
		2'd3: begin
			if (tx_strobe) begin
				tx_f_next_value <= 1'd1;
				tx_f_next_value_ce <= 1'd1;
				fsm1_next_state <= 1'd0;
			end
		end
		default: begin
			tx_ack <= 1'd1;
			if (tx_ready) begin
				tx_counter_t_next_value0 <= 2'd3;
				tx_counter_t_next_value_ce0 <= 1'd1;
				tx_latch_t_next_value1 <= tx_data;
				tx_latch_t_next_value_ce1 <= 1'd1;
				fsm1_next_state <= 1'd1;
			end else begin
				tx_f_next_value <= 1'd1;
				tx_f_next_value_ce <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d_1 <= dummy_s;
// synthesis translate_on
end

always @(posedge sys_clk) begin
	if ((rx_counter == 1'd0)) begin
		rx_counter <= 2'd3;
	end else begin
		rx_counter <= (rx_counter - 1'd1);
	end
	if ((tx_counter == 1'd0)) begin
		tx_counter <= 2'd3;
	end else begin
		tx_counter <= (tx_counter - 1'd1);
	end
	fsm0_state <= fsm0_next_state;
	if (rx_counter_next_value_ce0) begin
		rx_counter <= rx_counter_next_value0;
	end
	if (rx_data_next_value_ce1) begin
		rx_data <= rx_data_next_value1;
	end
	if (rx_bitno_next_value_ce2) begin
		rx_bitno <= rx_bitno_next_value2;
	end
	fsm1_state <= fsm1_next_state;
	if (tx_counter_t_next_value_ce0) begin
		tx_counter <= tx_counter_t_next_value0;
	end
	if (tx_latch_t_next_value_ce1) begin
		tx_latch <= tx_latch_t_next_value1;
	end
	if (tx_f_next_value_ce) begin
		tx <= tx_f_next_value;
	end
	if (tx_bitno_t_next_value_ce2) begin
		tx_bitno <= tx_bitno_t_next_value2;
	end
	if (sys_rst) begin
		rx_data <= 8'd0;
		tx <= 1'd0;
		rx_counter <= 2'd0;
		rx_bitno <= 3'd0;
		tx_counter <= 2'd0;
		tx_bitno <= 3'd0;
		tx_latch <= 8'd0;
		fsm0_state <= 3'd0;
		fsm1_state <= 2'd0;
	end
end

endmodule
