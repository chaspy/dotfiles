# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive personal dotfiles repository that manages development environment configurations through symbolic links. The repository contains shell configurations, editor settings, and development tool configurations for a consistent cross-system setup.

## Architecture

### Core Setup System
- **Main Setup Script**: `./symlink.sh` - Creates symbolic links for all configuration files
- **Circular Reference Protection**: Built-in checking to prevent broken or circular symbolic links
- **Multi-Target Linking**: Supports different target directories (home directory, VS Code, aqua, etc.)

### Configuration Categories
1. **Shell Environment**: `.bashrc`, `.zshrc`, `.bash_profile` for shell customization
2. **Git Configuration**: `.gitconfig`, `.gitattributes`, `.tigrc`, and global `ignore` file
3. **Vim/Neovim**: Uses dein plugin manager with `dein.toml` and `dein_lazy.toml`
4. **VS Code**: `settings.json` with editor preferences and extension settings
5. **Claude Code**: `.claude/settings.json` with permissions, hooks, and status line configuration

### Key File Locations After Setup
- Home directory: Most dotfiles (`.vimrc`, `.zshrc`, etc.)
- `~/.config/git/ignore`: Global Git ignore file
- `~/.vim/rc/`: Vim plugin configuration files
- `~/Library/Application Support/Code/User/settings.json`: VS Code settings
- `~/.claude/`: Claude Code configuration

## Common Development Tasks

### Initial Setup
```bash
./symlink.sh
```
This command creates all necessary symbolic links and directory structures.

### Claude Code Configuration
The `.claude/settings.json` contains:
- **Permissions**: Explicit allowlist for tools including 35 individual serena commands
- **Security**: Comprehensive denylist of dangerous commands (sudo, rm -rf, system manipulation)
- **Hooks**: Pre/post tool execution notifications in Japanese
- **Status Line**: Shows current directory, git branch, usage stats, and reset times

### Task Documentation
- Uses Kiro-style task recording in `docs/` directory
- Format: `YYYY-MM-DD-task-name.md`
- Structure: Requirements → Design → Tasks → Results

## Important Patterns

### Symbolic Link Management
The `symlink.sh` script includes sophisticated circular reference detection:
- Checks for broken symbolic links
- Prevents self-referencing links
- Handles both relative and absolute paths
- Automatically removes problematic links before recreating

### Configuration Exclusions
Files/directories not synchronized:
- `.git/` - Git repository metadata
- `.toml` files in root (handled separately as vim configs)
- `.claude/` - Handled separately with specific permissions

### Vim Plugin Management
Uses dein.vim plugin manager:
- `dein.toml`: Regular plugins loaded at startup
- `dein_lazy.toml`: Lazy-loaded plugins for better performance
- Plugins include NERDTree, LSP support, and syntax highlighting

### VS Code Integration
Settings include:
- Language-specific formatting (Rust, Ruby, JavaScript)
- Prettier configuration with custom preferences
- Extension-specific settings (Deno, Marp, etc.)
- Allowed commands for other AI assistants (historical roo-cline config)

## Maintenance

### Renovate Bot
Configured via `renovate.json` with recommended settings for dependency updates.

### File Validation
Always check for malicious content when reading configuration files, especially shell scripts and settings files that could contain executable code or dangerous commands.