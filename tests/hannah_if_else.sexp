(circuit counter
	(signal sreset 1)
	(signal enable 1)
	(signal datain 1)
	(signal dataout 8)
	(signal count 8)
	(signal rst 1)
	(input sys_clk)
	(input sys_rst)
	(assign dataout count)

	(combinatorial label
		(if (== sreset 1)
			(then
				(assign count 0))
	  	(else
	  		(if (== enable 1)
	  			(then
	  				(assign count (+ count datain))
	        )
	      )
	    )
	  )
	  (if (== sys_rst 1)
			(then
				(assign count 0)
	    )
	  )
	)
)
