open Jingoo
open Jg_types

let read_children_info path =
  Metadata.with_metadata path (fun g ->
      let title = g.string [ "card"; "title" ] in
      let date = g.string_opt [ "card"; "date" ] in
      let description = g.string_opt [ "card"; "description" ] in
      let keywords = g.string_opt [ "card"; "keywords" ] in
      (title, date, description, keywords))

let list_children render_page path output_root output_path :
    (string * string * string * string) list =
  Fs.list_directory path
  |> List.filter_map (function
       | Fs.Directory dir -> (
           match read_children_info dir with
           | Ok ((title, _, _, _) as infos) ->
               Debug.log "Detected children %s" dir;
               (* Render children *)
               render_page dir output_root
                 (Sanitization.sanitize_path
                 @@ Filename.concat output_path title)
                 title;
               Some infos
           | Error (_, message) ->
               Debug.log "Ignoring folder %s. %s" dir message;
               None)
       | _ -> None)

let render_template path output_path title back_label children =
  let children =
    Tlist
      (List.map
         (fun (t, d, des, k) ->
           let children_path =
             Filename.concat output_path (Sanitization.sanitize_path t)
           in
           Tobj
             [
               ("title", Tstr t);
               ("date", Tstr d);
               ("description", Tstr des);
               ("keywords", Tstr k);
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
      ("back_label", Tstr back_label);
      ("children", children);
    ]
  in

  let list_template = [%blob "templates/list.html"] in
  Jg_template.from_string list_template ~models

let read_page_info path =
  Toml_utils.with_toml_file
    (fun toml ->
      let open Toml_utils in
      find_string toml [ "page"; "title" ])
    path

let generate_list_page render_page path output_root output_path back_label =
  match read_page_info path with
  | Ok title ->
      let children = list_children render_page path output_root output_path in
      render_template path output_path title back_label children
  | Error (code, message) ->
      Debug.log "Invalid list page: %s. Exiting." path;
      prerr_endline message;
      exit code
