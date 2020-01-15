(circuit test_case
  (input val uint2)
  (output f  uint2)
  (signal next_state uint2)
  (comb label_c
    (case val
      (when 1
        (assign f 1)
        (assign next_state 2)
      )
      (when 2
        (assign f 2)
        (assign next_state 1)
      )
      (default
        (assign f 4)
        (if (== a 2)
          (then
            (assign f 3)
          )
        )
      )
    )
  )
)
