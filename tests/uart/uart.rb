require 'ruby_rtl'
 
include RubyRTL
 
class Uart < Circuit
  def initialize
    input :sys_rst => :bv1
    input :sys_clk => :bv1
    wire :[:name, :rx_data] => :
    wire :[:name, :rx_ready] => :
    wire :[:name, :rx_ack] => :
    wire :[:name, :next_value] => :
    wire :[:name, :rx_error] => :
    wire :[:name, :next_value_ce] => :
    wire :[:name, :tx_data] => :
    wire :[:name, :tx_ready] => :
    wire :[:name, :tx_ack] => :
    wire :[:name, :rx] => :
    wire :[:name, :tx] => :
    wire :[:name, :rx_counter] => :
    wire :[:name, :rx_strobe] => :
    wire :[:name, :rst] => :
    wire :[:name, :rx_bitno] => :
    wire :[:name, :tx_counter] => :
    wire :[:name, :tx_strobe] => :
    wire :[:name, :tx_bitno] => :
    wire :[:name, :tx_latch] => :
    wire :[:name, :state] => :
    wire :[:name, :next_state] => :
 
    assign(rx_strobe <= (rx_counter == 0))
    assign(tx_strobe <= (tx_counter == 0))
    combinatorial(){
      assign(rx_error <= 0)
      assign(fsm0_next_state <= 0)
      assign(rx_counter_next_value0 <= 0)
      assign(rx_counter_next_value_ce0 <= 0)
      assign(rx_data_next_value1 <= 0)
      assign(rx_data_next_value_ce1 <= 0)
      assign(rx_bitno_next_value2 <= 0)
      assign(rx_bitno_next_value_ce2 <= 0)
      assign(fsm0_next_state <= fsm0_state)
      Case(fsm0_state){
        When(1){
          If((rx_strobe == 1)){
            assign(fsm0_next_state <= 2)
          }
        }
        When(2){
          If((rx_strobe == 1)){
            assign(rx_data_next_value1 <= (rx_data[7..1] concat rx))
            assign(rx_data_next_value_ce1 <= 1)
            assign(rx_bitno_next_value2 <= (rx_bitno add 1))
            assign(rx_bitno_next_value_ce2 <= 1)
            If((rx_bitno == 7)){
              assign(fsm0_next_state <= 3)
            }
          }
        }
        When(3){
          If((rx_strobe == 1)){
            If((rx != 1)){
              assign(fsm0_next_state <= 5)
            Else{
              assign(fsm0_next_state <= 4)
            }
          }
        }
        When(5){
          assign(rx_error <= 1)
        }
        When(4){
          assign(rx_ready <= 1)
          If((rx_ack == 1)){
            assign(fsm0_next_state <= 0)
          Else{
            If((rx != 1)){
              assign(fsm0_next_state <= 5)
            }
          }
        }
        Else{
          If((rx != 1)){
            assign(rx_counter_next_value0 <= 2)
            assign(rx_counter_next_value_ce0 <= 1)
            assign(fsm0_next_state <= 1)
          }
        }
      }
    }
    combinatorial(){
      assign(fsm1_next_state <= 0)
      assign(tx_counter_t_next_value0 <= 0)
      assign(tx_counter_t_next_value_ce0 <= 0)
      assign(tx_latch_t_next_value1 <= 0)
      assign(tx_latch_t_next_value_ce1 <= 0)
      assign(tx_f_next_value <= 0)
      assign(tx_f_next_value_ce <= 0)
      assign(tx_bitno_t_next_value2 <= 0)
      assign(tx_bitno_t_next_value_ce2 <= 0)
      assign(fsm1_next_state <= fsm1_state)
      Case(fsm1_state){
        When(1){
          If((tx_strobe == 1)){
            assign(tx_f_next_value <= 0)
            assign(tx_f_next_value_ce <= 1)
            assign(fsm1_next_state <= 2)
          }
        }
        When(2){
          If((tx_strobe == 1)){
            assign(tx_f_next_value <= tx_latch[0..0])
            assign(tx_f_next_value_ce <= 1)
            assign(tx_latch_t_next_value1 <= (tx_latch[7..1] concat 0))
            assign(tx_latch_t_next_value_ce1 <= 1)
            assign(tx_bitno_t_next_value2 <= (tx_bitno add 1))
            assign(tx_bitno_t_next_value_ce2 <= 1)
            If((tx_bitno == 7)){
              assign(fsm1_next_state <= 3)
            }
          }
        }
        When(3){
          If((tx_strobe == 1)){
            assign(tx_f_next_value <= 1)
            assign(tx_f_next_value_ce <= 1)
            assign(fsm1_next_state <= 0)
          }
        }
        Else{
          assign(tx_ack <= 1)
          If((tx_ready == 1)){
            assign(tx_counter_t_next_value0 <= 3)
            assign(tx_counter_t_next_value_ce0 <= 1)
            assign(tx_latch_t_next_value1 <= tx_data)
            assign(tx_latch_t_next_value_ce1 <= 1)
            assign(fsm1_next_state <= 1)
          Else{
            assign(tx_f_next_value <= 1)
            assign(tx_f_next_value_ce <= 1)
          }
        }
      }
    }
    sequential(){
      If((rx_counter == 0)){
        assign(rx_counter <= 3)
      Else{
        assign(rx_counter <= (rx_counter sub 1))
      }
      If((tx_counter == 0)){
        assign(tx_counter <= 3)
      Else{
        assign(tx_counter <= (tx_counter sub 1))
      }
      assign(fsm0_state <= fsm0_next_state)
      If((rx_counter_next_value_ce0 == 1)){
        assign(rx_counter <= rx_counter_next_value0)
      }
      If((rx_data_next_value_ce1 == 1)){
        assign(rx_data <= rx_data_next_value1)
      }
      If((rx_bitno_next_value_ce2 == 1)){
        assign(rx_bitno <= rx_bitno_next_value2)
      }
      assign(fsm1_state <= fsm1_next_state)
      If((tx_counter_t_next_value_ce0 == 1)){
        assign(tx_counter <= tx_counter_t_next_value0)
      }
      If((tx_latch_t_next_value_ce1 == 1)){
        assign(tx_latch <= tx_latch_t_next_value1)
      }
      If((tx_f_next_value_ce == 1)){
        assign(tx <= tx_f_next_value)
      }
      If((tx_bitno_t_next_value_ce2 == 1)){
        assign(tx_bitno <= tx_bitno_t_next_value2)
      }
      If((sys_rst == 1)){
        assign(rx_data <= 0)
        assign(tx <= 0)
        assign(rx_counter <= 0)
        assign(rx_bitno <= 0)
        assign(tx_counter <= 0)
        assign(tx_bitno <= 0)
        assign(tx_latch <= 0)
        assign(fsm0_state <= 0)
        assign(fsm1_state <= 0)
      }
    }
  end
end
