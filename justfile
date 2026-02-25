default: install build

build:
  dune build

install: download_assets
  opam update
  opam install --yes . --deps-only

dev:
  dune exec ./course_manager.exe -- ssg course_structure --debug && python3 -m http.server 8080 -d output

clean:
  dune clean
  git clean -dfX
  rm -rf _docs/

doc:
  make clean
  dune build @doc
  mkdir _docs/
  cp  -r ./_build/default/_doc/_html/* _docs/

format:
  dune build @fmt --auto-promote

# Setup git commit hooks
hook:
  cp ./_hooks/* .git/hooks

download_assets: fonts-cm fonts-inter katex

# Download and extract the computer modern font
fonts-cm:
    mkdir -p static/fonts
    if [ ! -d "static/fonts/computer-modern" ]; then \
        git clone https://github.com/vsalvino/computer-modern static/fonts/computer-modern; \
    else \
        cd static/fonts/computer-modern && git pull; \
    fi

# Download and extract Inter font
fonts-inter:
    mkdir -p static/fonts/inter
    curl -L https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip -o inter.zip
    unzip -o inter.zip -d static/fonts/inter
    rm inter.zip

# Download and extract KaTeX
katex:
    mkdir -p static/katex
    curl -L https://github.com/KaTeX/KaTeX/releases/download/v0.16.21/katex.zip -o katex.zip
    unzip -o katex.zip -d static
    rm katex.zip
