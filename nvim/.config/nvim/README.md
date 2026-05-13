# Neovim Configuration

Lua-based Neovim config loaded from `init.lua`.

## Layout

- `init.lua`: entrypoint that loads `lua/config`.
- `lua/config/init.lua`: loads keymaps/options, bootstraps `lazy.nvim`, declares plugins, and applies the colorscheme.
- `lua/config/options.lua`: editor options.
- `lua/config/remap.lua`: general keymaps.
- `after/plugin/lsp.lua`: LSP, diagnostics, and completion mappings.
- `after/plugin/telescope.lua`: Telescope keymaps.
- `after/plugin/undotree.lua`: Undotree keymap.
- `colors/lizard256.vim`: colorscheme.

## Plugins

Plugins are managed with `lazy.nvim`, which is cloned automatically on first startup.

- `nvim-telescope/telescope.nvim`: fuzzy finding.
- `nvim-treesitter/nvim-treesitter`: syntax highlighting and indentation.
- `mbbill/undotree`: undo history browser.
- `tpope/vim-fugitive`: Git integration.
- `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`: LSP installation/configuration.
- `nvim-cmp`, `cmp-nvim-lsp`, `LuaSnip`: completion and snippets.

## Options

Notable defaults:

- Leader key is `,`.
- Two-space indentation with spaces.
- Line numbers and cursorline enabled.
- Case-insensitive search unless uppercase is used.
- Search highlighting enabled.
- Line wrapping disabled.
- Mouse disabled.
- Vertical splits open to the right.
- Modelines enabled, limited to one.

## Keymaps

General mappings live in `lua/config/remap.lua`.

- `,pv`: open netrw file explorer.
- `,<C-J>` / `,<C-K>`: previous/next buffer.
- `,n` / `,m`: first nonblank character / end of line.
- `,<Space>`: clear search highlight.
- Visual `J` / `K`: move selected lines down/up.
- `<C-d>` / `<C-u>`: half-page down/up and recenter.
- `,p`: paste over selection without replacing the paste register.
- `,d`: delete to the black-hole register.
- `,y` / `,Y`: yank to the system clipboard.
- `,f`: format with the active LSP.
- `,s`: substitute the word under the cursor.
- `,x`: make the current file executable.

Telescope mappings live in `after/plugin/telescope.lua`.

- `,ff`: find files.
- `,fc`: find Git-tracked files.
- `,fg`: live grep.
- `,fh`: help tags.

Undotree mapping:

- `,u`: toggle Undotree.

## LSP

LSP setup lives in `after/plugin/lsp.lua`.

Configured server:

- `ansiblels` for `yaml`, `yml`, and `ansible` files rooted at `playbooks` or `roles`.

LSP mappings are buffer-local and created only when an LSP attaches.

- `gd`: go to definition.
- `K`: hover documentation.
- `,vws`: workspace symbol.
- `,vd`: open diagnostic float.
- `[d` / `]d`: previous/next diagnostic.
- `,vca`: code action.
- `,vrr`: references.
- `,vrn`: rename.
- Insert `<C-h>`: signature help.

Completion mappings:

- `<C-p>` / `<C-n>`: previous/next completion item.
- `<CR>`: confirm completion.
- `<C-Space>`: trigger completion.
