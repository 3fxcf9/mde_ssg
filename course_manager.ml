open Cmdliner

let debug =
  let doc = "Print debug information to the console." in
  Arg.(value & flag & info [ "d"; "debug" ] ~doc)

let path =
  let doc = "The project root." in
  Arg.(value & pos 0 dir "." & info [] ~docv:"PATH" ~doc)

let output =
  let doc = "The directory to output to." in
  Arg.(value & pos 1 dir "output" & info [] ~docv:"OUTPUT" ~doc)

let http_root =
  let doc = "The base URL path for the generated site." in
  Arg.(value & opt string "/" & info [ "http-root" ] ~docv:"ROOT" ~doc)

let run_ssg _debug root output http_root : unit =
  ignore @@ Fs.create_dir_if_not_exists output;
  Ssg.copy_static output;
  let ensure_slash_end path =
    if String.ends_with ~suffix:"/" path then path else path ^ "/"
  in
  let ensure_shash_beg path =
    if String.starts_with ~prefix:"/" path then path else "/" ^ path
  in
  let http_root = ensure_slash_end @@ ensure_shash_beg http_root in
  Debug.log "Using HTTP_ROOT=%s" http_root;
  Ssg.render_path root output http_root "" ""

let ssg_t =
  Term.(
    const run_ssg
    $ (const Debug.set_enabled $ debug)
    $ path $ output $ http_root)

let ssg_cmd =
  let info = Cmd.info "ssg" ~doc:"Run the static site generator" in
  Cmd.v info ssg_t

let exits =
  Cmd.Exit.info 2 ~doc:"on missing configuration file."
  :: Cmd.Exit.info 3 ~doc:"on invalid configuration syntax."
  :: Cmd.Exit.info 4 ~doc:"on invalid mde syntax."
  :: Cmd.Exit.defaults

let main_cmd =
  let info = Cmd.info "mde_ssg" ~version:"0.1.0" ~doc:"Course manager" ~exits in
  Cmd.group info [ ssg_cmd ]

let () = exit (Cmd.eval main_cmd)
