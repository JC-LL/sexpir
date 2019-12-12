(circuit ha
   (input a bit)
   (input b bit)
   (output sum bit)
   (output cout bit)

   (assign sum (xor a b))
   (assign cout (and a b))
)
