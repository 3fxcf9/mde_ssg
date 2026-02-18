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

let run_ssg _debug root output =
  ignore @@ Fs.create_dir_if_not_exists output;
  Ssg.render_path root output ""

let ssg_t =
  Term.(const run_ssg $ (const Debug.set_enabled $ debug) $ path $ output)

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
