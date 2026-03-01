open Jingoo
open Jg_types

let render_template output_path title back_label toc_html html =
  let models =
    [
      ("title", Tstr title);
      ( "back_url",
        Tstr (if output_path = "" then "" else Filename.dirname output_path) );
      ("back_label", Tstr back_label);
      ("toc_html", Tstr toc_html);
      ("html", Tstr html);
    ]
  in

  let list_template = [%blob "templates/document.html"] in
  Jg_template.from_string list_template ~models

let generate_document_page mde_path output_path back_label =
  let content = In_channel.with_open_bin mde_path In_channel.input_all in
  let html, toc_html, meta = Mde_parser.parse_mde content in
  let title =
    match meta with
    | Some m ->
        Metadata.get_yaml_string (Metadata.find_yaml m [ "card"; "title" ])
    | None -> ""
  in
  render_template output_path title back_label toc_html html
