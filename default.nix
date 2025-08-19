let
 pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-08-11.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      languageserver
      tidyverse;
  };
     
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      glibcLocales
      nix
      R
      uv
      ;
  };

  shell = pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    
    buildInputs = [ rpkgs system_packages ];

    shellHook = ''
      # Export LD_LIBRARY is required for python packages that dynamically load libraries, such as numpy
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [ zlib stdenv.cc.cc ])}":LD_LIBRARY_PATH;

      if [ ! -f pyproject.toml ]; then
        uv init --python 3.13.5
      fi
        uv add --requirements requirements.txt
      # Create alias so 'python' uses uv's environment
      alias python="uv run python"
    '';
  }; 
in
  {
    inherit pkgs shell;
  }
