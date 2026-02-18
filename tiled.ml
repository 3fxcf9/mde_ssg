open Jingoo
open Jg_types

let read_children_info path =
  Metadata.with_metadata path (fun g ->
      let title = g.string [ "card"; "title" ] in
      let subtitle = g.string_opt [ "card"; "subtitle" ] in
      let right = g.string_opt [ "card"; "right" ] in
      (title, subtitle, right))

let list_children render_page path output_root output_path :
    (string * string * string) list =
  Fs.list_directory path
  |> List.filter_map (function
       | Fs.Directory dir -> (
           match read_children_info dir with
           | Ok ((title, _, _) as infos) ->
               Debug.log "Detected children %s" dir;
               (* Render children *)
               render_page dir output_root
                 (Sanitization.sanitize_path
                 @@ Filename.concat output_path title);
               Some infos
           | Error (_, message) ->
               Debug.log "Ignoring folder %s. %s" dir message;
               None)
       | _ -> None)

let render_template path output_path title right children =
  let children =
    Tlist
      (List.map
         (fun (t, s, r) ->
           let children_path =
             Filename.concat output_path (Sanitization.sanitize_path t)
           in
           Tobj
             [
               ("title", Tstr t);
               ("subtitle", Tstr s);
               ("right", Tstr r);
               ("path", Tstr children_path);
               (* TODO *)
               ( "cover",
                 Tstr (if false then Filename.concat path "cover.svg" else "")
               );
             ])
         children)
  in

  let models =
    [
      ("title", Tstr title);
      ( "back_url",
        Tstr (if output_path = "" then "" else Filename.dirname output_path) );
      ("right", Tstr right);
      ("children", children);
    ]
  in

  (* Jg_template.from_file "templates/tiled.html" ~models *)
  let list_template = [%blob "templates/tiled.html"] in
  Jg_template.from_string list_template ~models

let read_page_info path =
  Toml_utils.with_toml_file
    (fun toml ->
      let open Toml_utils in
      let title = find_string toml [ "page"; "title" ] in
      let right = find_string toml [ "page"; "right" ] in
      (title, right))
    path

let generate_tiled_page render_page path output_root output_path =
  match read_page_info path with
  | Ok (title, right) ->
      let children = list_children render_page path output_root output_path in
      render_template path output_path title right children
  | Error (code, message) ->
      Debug.log "Invalid tiled page: %s. Exiting." path;
      prerr_endline message;
      exit code
