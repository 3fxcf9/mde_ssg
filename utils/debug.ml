let enabled = ref false
let set_enabled b = enabled := b

let log fmt =
  if !enabled
  then
    Printf.kfprintf
      (fun _ -> ())
      stderr
      ("\027[33m[DEBUG]\027[0m " ^^ fmt ^^ "\n%!")
  else Printf.ifprintf stderr fmt
