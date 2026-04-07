--- Find the best compile_commands.json under a HANA build dir
---@param build_dir string
---@return string|nil profile_name
local function find_hana_profile(build_dir)
  local preferred = { "ClangOptimizedMold", "ClangOptimized", "Optimized" }
  for _, profile in ipairs(preferred) do
    if vim.uv.fs_stat(build_dir .. "/" .. profile .. "/compile_commands.json") then
      return profile
    end
  end
  local handle = vim.uv.fs_scandir(build_dir)
  if handle then
    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end
      if typ == "directory" and vim.uv.fs_stat(build_dir .. "/" .. name .. "/compile_commands.json") then
        return name
      end
    end
  end
  return nil
end

--- Resolve SAP-patched clangd binary via HappyMake
---@param cwd string
---@return string|nil
local function resolve_hm_clangd(cwd)
  local result = vim.system({ "hm", "tool", "--print-path", "clangd" }, { cwd = cwd, text = true }):wait()
  if result.code == 0 and result.stdout and result.stdout ~= "" then
    return vim.trim(result.stdout)
  end
  return nil
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        root_markers = {
          ".hmproject",
          "compile_commands.json",
          "compile_flags.txt",
          ".clang-tidy",
          ".clang-format",
          ".git",
        },
      },
    },
    setup = {
      ---@param _ string server name
      ---@param opts vim.lsp.Config
      clangd = function(_, opts)
        local root = vim.fs.root(vim.uv.cwd(), ".hmproject")
        if not root then
          return -- not a HANA repo, use LazyVim defaults
        end
        local clangd_bin = resolve_hm_clangd(root)
        if not clangd_bin then
          return
        end
        local profile = find_hana_profile(root .. "/build")
        local cmd = {
          clangd_bin,
          "--compile_args_from=filesystem",
          "--background-index",
          "-j=" .. math.max(1, #vim.uv.cpu_info()),
          "--log=error",
        }
        if profile then
          table.insert(cmd, 2, "--compile-commands-dir=" .. root .. "/build/" .. profile)
        end
        opts.cmd = cmd
        -- return nil: let LazyVim proceed with vim.lsp.config()/vim.lsp.enable()
      end,
    },
  },
}
