open Jingoo
open Jg_types

let render_template output_path http_root title back_label toc_html html =
  let models =
    [
      ("title", Tstr title);
      ( "back_url",
        Tstr (if output_path = "" then "" else Filename.dirname output_path) );
      ("back_label", Tstr back_label);
      ("toc_html", Tstr toc_html);
      ("html", Tstr html);
      ("http_root", Tstr http_root);
    ]
  in

  let list_template = [%blob "templates/document.html"] in
  Jg_template.from_string list_template ~models

(** [generate_figure_hashtable dir_path] reads a directory and returns a Hashtbl
    where keys are the filenames and values are the file contents. **)
let generate_figure_hashtable dir_path =
  let svg_table = Hashtbl.create 8 in

  let entries = Fs.list_directory dir_path in

  List.iter
    (function
      | Fs.File path ->
          if Filename.check_suffix path ".svg"
          then begin
            Debug.log ~cat:Figures "Detected figure at %s" path;
            let filename = Filename.basename path in
            let content = Fs.read_file path in
            Hashtbl.add svg_table filename content
          end
      | Fs.Directory _ -> ())
    entries;

  svg_table

let generate_document_page mde_path http_root output_path back_label =
  let content = Fs.read_file mde_path in
  let svg_table =
    generate_figure_hashtable
      (Filename.concat (Filename.dirname mde_path) "figures")
  in
  let html, toc_html, meta = Mde_parser.parse_mde ~figures:svg_table content in
  let title =
    match meta with
    | Some m ->
        Metadata.get_yaml_string (Metadata.find_yaml m [ "card"; "title" ])
    | None -> ""
  in
  render_template output_path http_root title back_label toc_html html
