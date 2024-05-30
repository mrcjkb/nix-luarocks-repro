rockspec_format = '3.0'
package = "testpackage"
version = "scm-1"
source = {
  url = "git+https://github.com/mrcjk/nix-luarocks-repro"
}
dependencies = {
  "lua >= 5.1",
  "luarocks",
}
build = {
  type = "builtin",
}
