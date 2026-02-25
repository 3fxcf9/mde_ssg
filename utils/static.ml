let unpack_assets target_dir =
  if not (Sys.file_exists target_dir)
  then ignore @@ Fs.create_dir_if_not_exists target_dir;

  List.iter
    (fun path ->
      match Static_assets.read path with
      | Some content ->
          let full_path = Filename.concat target_dir path in

          (* Ensure subdirectories exist *)
          let dir = Filename.dirname full_path in
          ignore @@ Fs.create_dir_if_not_exists dir;

          (* Write the file *)
          let oc = open_out full_path in
          output_string oc content;
          close_out oc;
          Debug.log ~cat:Assets "Unpacked: %s" path
      | None -> ())
    Static_assets.file_list
