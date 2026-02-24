# Agent Guidelines for nvf-config

## Build/Test/Lint Commands

- **Build**: `nix build` or `nix flake check` (validates flake configuration)
- **Format**: `nix fmt` (uses alejandra formatter for Nix code)
- **Test**: No specific test suite - validation is done through
  `nix flake check`
- **Dev shell**: `nix develop` (provides development environment with nvf-config
  and inspect tools)

## Code Style Guidelines

- **Language**: Nix configuration files for nvf (Neovim configuration framework)
- **Formatting**: Use alejandra formatter (configured in flake.nix)
- **Imports**: Use relative imports in default.nix files, group related imports
  together
- **Structure**: Follow modular organization - each feature in separate
  files/directories
- **Naming**: Use kebab-case for file names, camelCase for Nix attributes,
  prefer single-word names
- **Comments**: Minimal comments, prefer self-documenting code structure
- **Lua code**: Embedded Lua should follow standard Lua conventions with 2-space
  indentation
- **Keymaps**: Use descriptive descriptions for all keymaps, group related
  bindings
- **Configuration**: Use `let...in` blocks for local variables, inherit from lib
  where appropriate

## Architecture

- Main config in `config/default.nix` with modular imports
- Features organized by category: coding, editing, git, languages, navigation,
  notes, ui
- Each module should have a default.nix that imports sub-modules
- Use nvf's configuration schema and helper functions (lib.nvim.*)
