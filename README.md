# sexpir

Sexpir is a simple format for RTL circuit serialization.

**Warning** : experimental work-in-progress.

Sexpir aims at providing both a set of tools and a language-neutral expression of RTL traditionnal constructs, as found in :
* Traditionnal Hardware-description languages : VHDL and Verilog
* Recent Hardware DSLs like :
  * Python-based [Migen](http://github.com/m-labs/migen)
  * Ruby-based [RubyRTL](http://github.com/JC-LL/ruby_rtl)

## Examples

#### Basic assignments
~~~lisp
(circuit HalfAdder
  (input a bit)
  (input b bit)
  (output sum  bit)
  (output cout bit)

  (assign sum  (xor a b))
  (assign cout (and a b))
)
~~~

#### Hierarchical composition
~~~lisp
(circuit FullAdder

 (input a bit)
 (input b bit)
 (input cin bit)
 (output sum bit)
 (output cout bit)

 (component ha1 HalfAdder)
 (component ha2 HalfAdder)

 (connect a (port ha1 a) )
 (connect (port ha2 sum) (port ha1 b))
 (connect b (port ha2 a) )
 (connect cin (port ha2 b ))
 (connect (port ha1 sum) sum)
 (connect (port ha1 cout) tmp1)
 (connect (port ha2 cout) tmp2)

 (assign cout (or tmp1 tmp2))

)
~~~

#### Behavioral statements
~~~lisp
(circuit Counter
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
~~~


## How to install
Sexpir tools are written in Ruby and hosted in both Github for development and RubyGem for distribution.

* gem install sexpir


## Contact
Don't hesitate to drop me a mail if you like Sexpir, or found a bug etc.
I will try to do my best to consolidate, maintain and enhance Sexpir, if people find it usefull.

jean-christophe.le_lann at ensta-bretagne.fr
