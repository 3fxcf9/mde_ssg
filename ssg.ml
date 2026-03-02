let copy_static root =
  ignore @@ Fs.create_dir_if_not_exists root;
  Static.unpack_assets root;
  Debug.log ~cat:Assets "Assets successfully extracted"

let rec render_path source_path output_root http_root output_path caller_name :
    unit =
  match Fs.find_mde source_path with
  | Some _ ->
      Debug.log "Mde file detected at %s" source_path;
      let output_full_path = Filename.concat output_root output_path in
      if not (Sys.file_exists output_full_path)
      then Sys.mkdir output_full_path 0o755;
      ignore
      @@ Fs.write_file
           (Filename.concat output_full_path "index.html")
           (Document.generate_document_page source_path http_root output_path
              caller_name)
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
               (Tiled_menu.generate_tiled_page render_path source_path
                  output_root http_root output_path caller_name)
      | Ok "list" | Ok _ ->
          Debug.log "List menu detected at %s" source_path;
          let output_full_path = Filename.concat output_root output_path in
          if not (Sys.file_exists output_full_path)
          then Sys.mkdir output_full_path 0o755;
          ignore
          @@ Fs.write_file
               (Filename.concat output_full_path "index.html")
               (List_menu.generate_list_page render_path source_path output_root
                  http_root output_path caller_name)
      | Error (_, message) ->
          Debug.log "Invalid menu %s: %s" source_path message
    end
