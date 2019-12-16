
(circuit fa

 (input a bit)
 (input b bit)
 (input cin bit)
 (output sum bit)
 (output cout bit)

 (component ha1 ha)
 (component ha2 ha)

 (connect a (port ha1 a) )
 (connect (port ha2 sum) (port ha1 b))
 (connect b (port ha2 a) )
 (connect cin (port ha2 b ))
 (connect (port ha1 sum) sum)
 (connect (port ha1 cout) tmp1)
 (connect (port ha2 cout) tmp2)

 (assign cout (or tmp1 tmp2))

)
