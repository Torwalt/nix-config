rec {
  # Function to get all files recursively from a directory
  getAllFiles = dir:
    let
      dirContents = builtins.readDir dir;

      isFile = name: dirContents.${name} == "regular";
      isDir = name: dirContents.${name} == "directory";

      dirEntryNames = builtins.attrNames dirContents;

      fileNames = builtins.filter isFile dirEntryNames;
      filePaths = map (name: toString (dir + "/${name}")) fileNames;

      dirNames = builtins.filter isDir dirEntryNames;
      dirPaths = map (name: dir + "/${name}") dirNames;

      subDirFiles = builtins.concatMap (subDir: getAllFiles subDir) dirPaths;
    in filePaths ++ subDirFiles;

  # Function to read specific directories in a precise order for Neovim config
  readNeovimConfig = baseDir: dirOrder:
    let
      # Convert directory names to full paths
      fullPaths = map (dir: baseDir + "/${dir}") dirOrder;
      # Get all Lua files from each directory, preserving order
      getLuaFilesFromDir = dir:
        let
          allFiles = getAllFiles dir;
          luaFiles =
            builtins.filter (file: builtins.match ".*\\.lua$" file != null)
            allFiles;
        in luaFiles;
      allLuaFiles = builtins.concatLists (map getLuaFilesFromDir fullPaths);
      # Read each file and format with the file path as a comment
      readFile = file: ''
        -- ${file}
        ${builtins.readFile file}
      '';
      # Map over all Lua files, read them, and join with newlines
      fileContents =
        builtins.concatStringsSep "\n\n" (map readFile allLuaFiles);
    in fileContents;
}
