#!/usr/bin/awk -f
  function print_unary_child_arrow(id, child_id) {
    if (child_id < 0)
      printf "%d -> %d [arrowhead = \"dot\"]\n", id, -child_id
    else 
      printf "%d -> %d [arrowhead = \"normal\"]\n", id, child_id
  }

  function print_child_arrow (id, child_id, op) {
    if (child_id < 0)
      printf "%d -> %d [arrowhead = \"dot\", taillabel=\"%d\"];\n", id,
					       -child_id, op
    else 
      printf "%d -> %d [arrowhead = \"normal\", taillabel=\"%d\"];\n", 
						id, child_id, op
  }

  BEGIN { print "digraph G {" } 

  { if ($2 == "const" || $2 == "constd" || $2 == "consth") { 
      printf "%d [shape=box, label=\"%s\\n%s\"];\n", $1, $2, $4
    } else if ($2 == "zero") {
      printf "%d [shape=box, label=\"zero\\n\"];\n", $1
    } else if ($2 == "var") {
    if (NF == 3)
      printf "%d [shape=box, label=\"var\\n%d\"];\n", $1, $3
    else if (NF > 3)
      printf "%d [shape=box, label=\"%s\\n%d\"];\n", $1, $4, $3
  } else if ($2 == "array") {
    arrays[$1]
    printf "%d [shape=box, style=filled, fillcolor=lightblue, label=\"array\\n%d %d\"];\n", $1, $3, $4
  } else if ($2 == "neg" || $2 == "not" || $2 == "redor" || $2 == "proxy" ||
             $2 == "redxor" || $2 == "redand" || $2 == "nego") {
    printf "%d [label=\"%s\"];\n", $1, $2
    print_unary_child_arrow($1, $4)
  } else if ($2 == "slice"){
    printf "%d [label=\"slice\\n%d %d\"];\n", $1, $5, $6
    print_unary_child_arrow($1, $4)
  } else if ($2 == "cond"){
    printf "%d [label=\"cond\"];\n", $1
    print_child_arrow($1, $4, 1)
    print_child_arrow($1, $5, 2)
    print_child_arrow($1, $6, 3)
  } else if ($2 == "acond"){ 
    arrays[$1]
    printf "%d [style=filled, fillcolor=lightcyan, label=\"acond\"];\n", $1
    print_child_arrow($1, $5, 1)
    print_child_arrow($1, $6, 2)
    print_child_arrow($1, $7, 3)
  } else if ($2 == "write"){
    arrays[$1]
    printf "%d [style=filled, fillcolor=lightgray, label=\"write\"];\n", $1
    print_child_arrow($1, $5, 1)
    print_child_arrow($1, $6, 2)
    print_child_arrow($1, $7, 3)
  } else if ($2 == "root"){
    printf "%d [shape=none, label=\"\"];\n", $1
    print_unary_child_arrow($1, $4)
  } else if ($2 == "read"){
    printf "%d [style=filled, fillcolor=lightyellow, label=\"read\"];\n", $1
    print_child_arrow($1, $4, 1)
    print_child_arrow($1, $5, 2)
  } else if ($2 == "sext" || $2 == "uext") {
    printf "%d [label=\"%s\\n%d\"];\n", $1, $2, $5
    print_unary_child_arrow($1, $4)
  } else if ($2 == "eq" || $2 == "ne"){
    if ($4 in arrays){
      printf "%d [shape=octagon, label=\"%s\"];\n", $1, $2
    } else {
      printf "%d [label=\"%s\"];\n", $1, $2
    } 
    print_child_arrow($1, $4, 1)
    print_child_arrow($1, $5, 2)
  } else if (NF == 5) {
    printf "%d [label=\"%s\"];\n", $1, $2
    print_child_arrow($1, $4, 1)
    print_child_arrow($1, $5, 2)
  }
}

END { print "}" }
