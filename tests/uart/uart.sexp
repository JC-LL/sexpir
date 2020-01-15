
(circuit uart
  (signal
    (name rx_data)
    (bits_sign 8))
  (signal
    (name rx_ready)
    (bits_sign 1))
  (signal
    (name rx_ack)
    (bits_sign 1))
  (signal
    (name next_value)
    (bits_sign 3))
  (signal
    (name rx_error)
    (bits_sign 1))
  (signal
    (name next_value_ce)
    (bits_sign 1))
  (signal
    (name tx_data)
    (bits_sign 8))
  (signal
    (name tx_ready)
    (bits_sign 1))
  (signal
    (name tx_ack)
    (bits_sign 1))
  (signal
    (name rx)
    (bits_sign 1)
    (reset 1))
  (signal
    (name tx)
    (bits_sign 1))
  (signal
    (name rx_counter)
    (bits_sign 2))
  (signal
    (name rx_strobe)
    (bits_sign 1))
  (signal
    (name rst)
    (bits_sign 1))
  (signal
    (name rx_bitno)
    (bits_sign 3))
  (signal
    (name tx_counter)
    (bits_sign 2))
  (signal
    (name tx_strobe)
    (bits_sign 1))
  (signal
    (name tx_bitno)
    (bits_sign 3))
  (signal
    (name tx_latch)
    (bits_sign 8))
  (signal
    (name state)
    (bits_sign 3))
  (signal
    (name next_state)
    (bits_sign 3))
  (input sys_rst 1)
  (input sys_clk 1)
  (assign rx_strobe
    (== rx_counter 0))
  (assign tx_strobe
    (== tx_counter 0))
  (comb
    (assign rx_ready 0)
    (assign rx_error 0)
    (assign fsm0_next_state 0)
    (assign rx_counter_next_value0 0)
    (assign rx_counter_next_value_ce0 0)
    (assign rx_data_next_value1 0)
    (assign rx_data_next_value_ce1 0)
    (assign rx_bitno_next_value2 0)
    (assign rx_bitno_next_value_ce2 0)
    (assign fsm0_next_state fsm0_state)
    (case fsm0_state
      (when 1
        (if
          (== rx_strobe 1)
          (then
            (assign fsm0_next_state 2))))
      (when 2
        (if
          (== rx_strobe 1)
          (then
            (assign rx_data_next_value1
              (concat
                (slice rx_data 7 1) rx))
            (assign rx_data_next_value_ce1 1)
            (assign rx_bitno_next_value2
              (+ rx_bitno 1))
            (assign rx_bitno_next_value_ce2 1)
            (if
              (== rx_bitno 7)
              (then
                (assign fsm0_next_state 3))))))
      (when 3
        (if
          (== rx_strobe 1)
          (then
            (if
              (!= rx 1)
              (then
                (assign fsm0_next_state 5))
              (else
                (assign fsm0_next_state 4))))))
      (default
        (if
          (!= rx 1)
          (then
            (assign rx_counter_next_value0 2)
            (assign rx_counter_next_value_ce0 1)
            (assign fsm0_next_state 1))))
      (when 5
        (assign rx_error 1))
      (when 4
        (assign rx_ready 1)
        (if
          (== rx_ack 1)
          (then
            (assign fsm0_next_state 0))
          (else
            (if
              (!= rx 1)
              (then
                (assign fsm0_next_state 5))))))))
  (comb
    (assign tx_ack 0)
    (assign fsm1_next_state 0)
    (assign tx_counter_t_next_value0 0)
    (assign tx_counter_t_next_value_ce0 0)
    (assign tx_latch_t_next_value1 0)
    (assign tx_latch_t_next_value_ce1 0)
    (assign tx_f_next_value 0)
    (assign tx_f_next_value_ce 0)
    (assign tx_bitno_t_next_value2 0)
    (assign tx_bitno_t_next_value_ce2 0)
    (assign fsm1_next_state fsm1_state)
    (case fsm1_state
      (when 1
        (if
          (== tx_strobe 1)
          (then
            (assign tx_f_next_value 0)
            (assign tx_f_next_value_ce 1)
            (assign fsm1_next_state 2))))
      (when 2
        (if
          (== tx_strobe 1)
          (then
            (assign tx_f_next_value
              (slice tx_latch 0 0))
            (assign tx_f_next_value_ce 1)
            (assign tx_latch_t_next_value1
              (concat
                (slice tx_latch 7 1) 0))
            (assign tx_latch_t_next_value_ce1 1)
            (assign tx_bitno_t_next_value2
              (+ tx_bitno 1))
            (assign tx_bitno_t_next_value_ce2 1)
            (if
              (== tx_bitno 7)
              (then
                (assign fsm1_next_state 3))))))
      (when 3
        (if
          (== tx_strobe 1)
          (then
            (assign tx_f_next_value 1)
            (assign tx_f_next_value_ce 1)
            (assign fsm1_next_state 0))))
      (default
        (assign tx_ack 1)
        (if
          (== tx_ready 1)
          (then
            (assign tx_counter_t_next_value0 3)
            (assign tx_counter_t_next_value_ce0 1)
            (assign tx_latch_t_next_value1 tx_data)
            (assign tx_latch_t_next_value_ce1 1)
            (assign fsm1_next_state 1))
          (else
            
              (assign tx_f_next_value 1)
              (assign tx_f_next_value_ce 1))))))
  (sequential nil
    (if
      (== rx_counter 0)
      (then
        (assign rx_counter 3))
      (else
        (assign rx_counter
          (- rx_counter 1))))
    (if
      (== tx_counter 0)
      (then
        (assign tx_counter 3))
      (else
        (assign tx_counter
          (- tx_counter 1))))
    (assign fsm0_state fsm0_next_state)
    (if
      (== rx_counter_next_value_ce0 1)
      (then
        (assign rx_counter rx_counter_next_value0)))
    (if
      (== rx_data_next_value_ce1 1)
      (then
        (assign rx_data rx_data_next_value1)))
    (if
      (== rx_bitno_next_value_ce2 1)
      (then
        (assign rx_bitno rx_bitno_next_value2)))
    (assign fsm1_state fsm1_next_state)
    (if
      (== tx_counter_t_next_value_ce0 1)
      (then
        (assign tx_counter tx_counter_t_next_value0)))
    (if
      (== tx_latch_t_next_value_ce1 1)
      (then
        (assign tx_latch tx_latch_t_next_value1)))
    (if
      (== tx_f_next_value_ce 1)
      (then
        (assign tx tx_f_next_value)))
    (if
      (== tx_bitno_t_next_value_ce2 1)
      (then
        (assign tx_bitno tx_bitno_t_next_value2)))
    (if
      (== sys_rst 1)
      (then
        (assign rx_data 0)
        (assign tx 0)
        (assign rx_counter 0)
        (assign rx_bitno 0)
        (assign tx_counter 0)
        (assign tx_bitno 0)
        (assign tx_latch 0)
        (assign fsm0_state 0)
        (assign fsm1_state 0)))))
