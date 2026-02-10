-- Build and run system for various languages
-- Supports C, C++, Python, Rust with CMake support
--
-- Keybindings (in mappings.lua):
--   <leader>bb - Build current file/project
--   <leader>br - Run current file/project
--   <leader>bR - Build AND run (or just F9)
--   <leader>bc - Clean build artifacts
--   <leader>bx - Build release (Rust only)
--
-- Language support:
--   C: gcc (single file) or CMake (if CMakeLists.txt exists)
--   C++: g++ (single file) or CMake (if CMakeLists.txt exists)
--   Python: python3 (no build step)
--   Rust: rustc (single file) or cargo (if Cargo.toml exists)

local M = {}

-- Build and run configurations for different filetypes
M.configs = {
    c = {
        single_file = {
            build = "gcc -Wall -Wextra -g '%:p' -o '%:p:r'",
            run = "'%:p:r'",
        },
        cmake = {
            build = "cmake -B build && cmake --build build",
            run = "./build/%:t:r",
        },
    },
    cpp = {
        single_file = {
            build = "g++ -Wall -Wextra -std=c++17 -g '%:p' -o '%:p:r'",
            run = "'%:p:r'",
        },
        cmake = {
            build = "cmake -B build && cmake --build build",
            run = "./build/%:t:r",
        },
    },
    python = {
        single_file = {
            build = "",  -- No build step needed
            run = "python3 '%:p'",
        },
    },
    rust = {
        single_file = {
            build = "rustc '%:p' -o '%:p:r'",
            run = "'%:p:r'",
        },
        cargo = {
            build = "cargo build",
            run = "cargo run",
            release = "cargo build --release && cargo run --release",
        },
    },
}

-- Detect if CMakeLists.txt exists in project
local function has_cmake()
    local cmake_file = vim.fn.findfile("CMakeLists.txt", ".;")
    return cmake_file ~= ""
end

-- Detect if Cargo.toml exists in project
local function has_cargo()
    local cargo_file = vim.fn.findfile("Cargo.toml", ".;")
    return cargo_file ~= ""
end

-- Get appropriate config for current filetype
function M.get_config()
    local ft = vim.bo.filetype
    local config = M.configs[ft]
    
    if not config then
        vim.notify("No build config for filetype: " .. ft, vim.log.levels.WARN)
        return nil
    end
    
    -- Select appropriate build system
    if ft == "c" or ft == "cpp" then
        if has_cmake() then
            return config.cmake
        else
            return config.single_file
        end
    elseif ft == "rust" then
        if has_cargo() then
            return config.cargo
        else
            return config.single_file
        end
    else
        return config.single_file
    end
end

-- Build current file/project
function M.build()
    local config = M.get_config()
    if not config or config.build == "" then
        vim.notify("No build step needed", vim.log.levels.INFO)
        return
    end
    
    local cmd = vim.fn.expandcmd(config.build)
    vim.cmd("wa")  -- Save all files
    vim.cmd("split | terminal " .. cmd)
end

-- Run current file/project
function M.run()
    local config = M.get_config()
    if not config then return end
    
    local cmd = vim.fn.expandcmd(config.run)
    vim.cmd("split | terminal " .. cmd)
end

-- Build and run
function M.build_and_run()
    local config = M.get_config()
    if not config then return end
    
    vim.cmd("wa")  -- Save all files
    
    local cmd
    if config.build and config.build ~= "" then
        cmd = vim.fn.expandcmd(config.build .. " && " .. config.run)
    else
        cmd = vim.fn.expandcmd(config.run)
    end
    
    vim.cmd("split | terminal " .. cmd)
end

-- Build release and run (for Rust)
function M.build_release()
    local ft = vim.bo.filetype
    if ft ~= "rust" then
        vim.notify("Release build only supported for Rust", vim.log.levels.WARN)
        return
    end
    
    local config = M.get_config()
    if config.release then
        vim.cmd("wa")
        local cmd = vim.fn.expandcmd(config.release)
        vim.cmd("split | terminal " .. cmd)
    end
end

-- Clean build artifacts
function M.clean()
    local ft = vim.bo.filetype
    
    if ft == "c" or ft == "cpp" then
        if has_cmake() then
            vim.cmd("!rm -rf build")
        else
            -- Clean compiled binary
            local binary = vim.fn.expand("%:p:r")
            vim.fn.delete(binary)
        end
    elseif ft == "rust" then
        if has_cargo() then
            vim.cmd("!cargo clean")
        else
            local binary = vim.fn.expand("%:p:r")
            vim.fn.delete(binary)
        end
    end
    
    vim.notify("Build artifacts cleaned", vim.log.levels.INFO)
end

-- Setup autocommands for language-specific settings
function M.setup_autocmds()
    local augroup = vim.api.nvim_create_augroup("LanguageBuildSystem", { clear = true })
    
    -- C/C++ settings
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp" },
        group = augroup,
        callback = function()
            vim.bo.makeprg = has_cmake() and "cmake --build build" or "make"
        end,
    })
    
    -- Rust settings
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        group = augroup,
        callback = function()
            vim.bo.makeprg = has_cargo() and "cargo build" or "rustc %"
        end,
    })
    
    -- Python settings
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        group = augroup,
        callback = function()
            vim.bo.makeprg = "python3 %"
        end,
    })
end

-- Create user commands
function M.setup_commands()
    vim.api.nvim_create_user_command("Build", M.build, {})
    vim.api.nvim_create_user_command("Run", M.run, {})
    vim.api.nvim_create_user_command("BuildRun", M.build_and_run, {})
    vim.api.nvim_create_user_command("BuildRelease", M.build_release, {})
    vim.api.nvim_create_user_command("CleanBuild", M.clean, {})
end

-- Main setup function
function M.setup()
    M.setup_autocmds()
    M.setup_commands()
end

return M
