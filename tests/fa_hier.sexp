
(circuit fa

 (input a bit)
 (input b bit)
 (input cin bit)
 (output sum bit)
 (output cout bit)

 (component ha1 ha)
 (component ha2 ha)

 (connect a (ha1 a) )
 (connect (ha2 sum) (ha1 b))
 (connect b (ha2 a) )
 (connect cin (ha2 b ))
 (connect (ha1 sum) sum)
 (connect (port ha1 cout) tmp1)
 (connect (port ha2 cout) tmp2)

 (assign cout (or tmp1 tmp2))

)
