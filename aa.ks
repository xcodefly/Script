run "_node.KS.".
clearscreen.
set tunePrograde to 10.
parameter targetApoapsis to 120000.
//set candidateNode to queue(lexicon()).
set tNode to GaNode(20).
//print candidateNode.

until tnode[0]["error"]<10
{
    set tnode to evolveNode(tnode).
    set tNode to evaluateApoapsis(tNode,targetApoapsis).
    set tNode to sortNode(tNode).
  //  print "Hello".
    printNode(tnode).  This is test.
  //  wait 2.
    
}


