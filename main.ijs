NB. main.ijs - J OpenWhisk script
NB.      expects JSON in arg2 of boxed ARGV input
NB.      returns JSON output
main =: 3 : 0
  outstr =. '{ "result" : { '
  for_i. y do.
    if. '"' e. ;i do.
      outstr =. outstr, '"arg',(": i_index),'" : "',(('"';'\"') stringreplace ;i),'", '
    else.
      outstr =. outstr, '"arg',(": i_index),'" : "',(;i),'", '
    end.
  end.
  outstr, '"msg":"that''s all folks!"}}'
)

