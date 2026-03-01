(* let enabled = ref false *)
(**)
(* let log fmt = *)
(*   if !enabled *)
(*   then *)
(*     Printf.kfprintf *)
(*       (fun _ -> ()) *)
(*       stderr *)
(*       ("\027[33m[DEBUG]\027[0m " ^^ fmt ^^ "\n%!") *)
(*   else Printf.ifprintf stderr fmt *)

type category = General | Assets | Figures

let active_categories = ref [ General; Assets; Figures ]
let is_enabled cat = List.mem cat !active_categories
let enabled = ref true
let set_enabled b = enabled := b

let log ?(cat = General) fmt =
  if !enabled && is_enabled cat
  then
    let prefix =
      match cat with
      | Assets -> "\027[34m[ASSETS]\027[0m "
      | General -> "\027[33m[DEBUG]\027[0m  "
      | Figures -> "\027[35m[DEBUG]\027[0m  "
    in
    let prefix_fmt = Scanf.format_from_string prefix "" in
    Printf.kfprintf (fun _ -> ()) stderr (prefix_fmt ^^ fmt ^^ "\n%!")
  else Printf.ifprintf stderr fmt
