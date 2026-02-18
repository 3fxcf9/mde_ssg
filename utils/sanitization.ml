let sanitize_path (s : string) : string =
  let open String in
  let s = Ubase.from_utf8 ~strip:"" s |> String.lowercase_ascii in
  (* Replace spaces with dash *)
  let buf = Buffer.create (length s) in
  String.iter
    (fun c ->
      match c with
      | 'a' .. 'z' | '0' .. '9' -> Buffer.add_char buf c
      | ' ' | '-' | '_' -> Buffer.add_char buf '-'
      | '/' -> Buffer.add_char buf '/'
      | _ -> ())
    s;
  (* Collapse multiple '-' *)
  let s' = Buffer.contents buf in
  let len = length s' in
  let buf2 = Buffer.create len in
  let rec loop i prev_dash =
    if i >= len
    then ()
    else
      let c = s'.[i] in
      if c = '-'
      then begin
        if not prev_dash then Buffer.add_char buf2 c;
        loop (i + 1) true
      end
      else begin
        Buffer.add_char buf2 c;
        loop (i + 1) false
      end
  in
  loop 0 false;
  (* Trim leading/trailing '-' *)
  let r = Buffer.contents buf2 in
  let len = length r in
  let i0 =
    let rec f i =
      if i >= len then len else if r.[i] = '-' then f (i + 1) else i
    in
    f 0
  in
  let i1 =
    let rec f i = if i < 0 then -1 else if r.[i] = '-' then f (i - 1) else i in
    f (len - 1)
  in
  if i0 > i1 then "" else sub r i0 (i1 - i0 + 1)
