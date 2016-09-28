REBOL [
    Purpose: {
    		Search through nested block. Relies on recusion design.
    }
    Note: {
    }
    History: [
    ]
    Title:   none
    Creation:    none
    Name:    none
	  Version: 
	  File:   %deepfind.r
    Rights:  none
    Origin: "Joel Neely" 
    Source: http://www.rebol.org/ml-display-thread.r?m=rmlMCDS
    ] 
]

deepfind: func [
	b [block!] 
	v [any-type!] 
	/local c d
][

  ;; either base case test is true so return d
  ;; or break down into a smaller step toward base case
  ;; in this case, the next block encountered
  ;; look inside it through another call to deepfind 
	
  either found? d: find b v [
    d
  ][
    c: b
    forall c [
      if all [block? d: first c  d: deepfind d v][
          return d
      ]
    ]
    none
  ]
]
