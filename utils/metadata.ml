type source = Yaml of Yaml.value | Toml of Otoml.t

type metadata_getters = {
  string : string list -> string;
  string_opt : string list -> string;
}

exception Key_error of string
exception Type_error of string

(* YAML *)
let rec find_yaml (v : Yaml.value) path =
  match path with
  | [] -> v
  | key :: rest -> (
      match v with
      | `O dict -> (
          match List.assoc_opt key dict with
          | Some sub -> find_yaml sub rest
          | None -> raise (Key_error key))
      | _ -> raise (Type_error key))

let get_yaml_string = function
  | `String s -> s
  | `Float f -> string_of_float f (* Yaml often parses numbers as floats *)
  | _ -> raise (Type_error "Expected string")

(* Unified *)
let find_string source path =
  match source with
  | Toml t -> (
      try Otoml.find t Otoml.get_string path with
      | Otoml.Key_error _ -> raise (Key_error (String.concat "." path))
      | Otoml.Type_error _ -> raise (Type_error (String.concat "." path)))
  | Yaml y -> (
      try get_yaml_string (find_yaml y path) with
      | Key_error _ -> raise (Key_error (String.concat "." path))
      | Type_error _ -> raise (Type_error (String.concat "." path)))

let find_string_optional source path =
  try find_string source path with _ -> ""

let with_metadata path f =
  let toml_path = Filename.concat path "info.toml" in
  let mde_path_opt = Fs.find_mde path in

  let make_getters src =
    {
      string = (fun p -> find_string src p);
      string_opt = (fun p -> find_string_optional src p);
    }
  in

  let metadata =
    match mde_path_opt with
    | Some p ->
        print_endline p;
        let _, _, meta = Mde_parser.parse_mde (Fs.read_file p) in
        (meta, p)
    | None -> (None, "")
  in

  match metadata with
  | Some yaml_data, p -> (
      try Ok (f (make_getters (Yaml yaml_data))) with
      | Key_error k -> Error (3, Printf.sprintf "Missing key '%s' in %s" k p)
      | Type_error k -> Error (3, Printf.sprintf "Type error for '%s' in %s" k p)
      | _ -> Error (3, "Error processing YAML in " ^ p))
  | None, _ -> (
      try
        let toml = Otoml.Parser.from_file toml_path in
        Ok (f (make_getters (Toml toml)))
      with
      | Sys_error _ ->
          Error (2, "No metadata source found (tried .mde and .toml)")
      | Otoml.Key_error k -> Error (3, "Missing TOML key: " ^ k)
      | _ -> Error (3, "General error in " ^ toml_path))
