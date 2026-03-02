let parse_date s =
  try Scanf.sscanf s "%d/%d/%d" (fun d m y -> Some (y, m, d)) with _ -> None

let compare_dates a b =
  match (parse_date a, parse_date b) with
  | Some da, Some db -> compare da db
  | None, None -> 0
  | None, Some _ -> -1 (* Valid dates first (in the reversed sorting) *)
  | Some _, None -> 1
