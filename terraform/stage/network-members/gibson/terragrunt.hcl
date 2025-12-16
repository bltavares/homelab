include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name = path_relative_to_include()
}
