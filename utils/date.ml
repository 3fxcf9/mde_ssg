let parse_date s = Scanf.sscanf s "%d/%d/%d" (fun d m y -> (y, m, d))
let compare_dates a b = try compare (parse_date a) (parse_date b) with _ -> 0
