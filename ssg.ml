open Jingoo
open Jg_types

let render_template output_path title back_label html =
  let models =
    [
      ("title", Tstr title);
      ( "back_url",
        Tstr (if output_path = "" then "" else Filename.dirname output_path) );
      ("back_label", Tstr back_label);
      ("html", Tstr html);
    ]
  in

  let list_template = [%blob "templates/document.html"] in
  Jg_template.from_string list_template ~models

(** Calls the right renderer for the given directory and writes the result at
    the correct output location *)
let rec render_path source_path output_root output_path =
  match Fs.find_mde source_path with
  | Some mde_path ->
      Debug.log "Mde file detected at %s" source_path;
      let output_full_path = Filename.concat output_root output_path in
      if not (Sys.file_exists output_full_path)
      then Sys.mkdir output_full_path 0o755;
      let content = In_channel.with_open_bin mde_path In_channel.input_all in
      let html, meta = Mde_parser.parse_mde content in
      let title =
        match meta with
        | Some m ->
            Metadata.get_yaml_string (Metadata.find_yaml m [ "card"; "title" ])
        | None -> ""
      in
      let page = render_template output_path title "Back" html in
      ignore
      @@ Fs.write_file (Filename.concat output_full_path "index.html") page
  | None -> begin
      match
        Toml_utils.with_toml_file
          (fun toml ->
            let open Toml_utils in
            let template = find_string toml [ "page"; "template" ] in
            template)
          source_path
      with
      | Ok "tiled" ->
          Debug.log "Tiled menu detected at %s" source_path;
          let output_full_path = Filename.concat output_root output_path in
          if not (Sys.file_exists output_full_path)
          then Sys.mkdir output_full_path 0o755;
          ignore
          @@ Fs.write_file
               (Filename.concat output_full_path "index.html")
               (Tiled.generate_tiled_page render_path source_path output_root
                  output_path)
      | Ok "list" | Ok _ ->
          Debug.log "List menu detected at %s" source_path;
          let output_full_path = Filename.concat output_root output_path in
          if not (Sys.file_exists output_full_path)
          then Sys.mkdir output_full_path 0o755;
          ignore
          @@ Fs.write_file
               (Filename.concat output_full_path "index.html")
               (List_menu.generate_list_page render_path source_path output_root
                  output_path)
      | Error (_, message) ->
          Debug.log "Invalid menu %s: %s" source_path message
    end
