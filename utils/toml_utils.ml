exception Key_error of string
exception Type_error of string

let find_string toml path =
  try Otoml.find toml Otoml.get_string path with
  | Otoml.Key_error _ -> raise (Key_error (String.concat "." path))
  | Otoml.Type_error _ -> raise (Type_error (String.concat "." path))

let find_string_optional toml path =
  try Otoml.find toml Otoml.get_string path with _ -> ""

let with_toml_file f path =
  let info_path = Filename.concat path "info.toml" in

  try let toml = Otoml.Parser.from_file info_path in

      Ok (f toml) with
  | Sys_error _ -> Error (2, Printf.sprintf "File not found: %s" info_path)
  | Key_error k -> Error (3, Printf.sprintf "Missing key '%s' in %s" k info_path)
  | Type_error k ->
      Error (3, Printf.sprintf "Invalid type for key '%s' in %s" k info_path)
  | _ -> Error (3, Printf.sprintf "General TOML error in %s" info_path)
