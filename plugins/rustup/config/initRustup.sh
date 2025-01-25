#!/bin/sh
set -eu

generate_rustup_completions() {
    # Detect current shell
    local shell=$(basename "$SHELL")

    case "$shell" in
        bash)
            # Check if on macOS or Linux
            if [[ "$OSTYPE" == "darwin"* ]]; then
                local completion_dir="$(brew --prefix)/etc/bash_completion.d"
                mkdir -p "$completion_dir"
                rustup completions bash > "$completion_dir/rustup.bash-completion"
                rustup completions bash cargo > "$completion_dir/cargo.bash-completion"
                echo "Rustup completions for Bash (macOS/Homebrew) added to: $completion_dir"
            else
                local completion_dir="$HOME/.local/share/bash-completion/completions"
                mkdir -p "$completion_dir"
                rustup completions bash > "$completion_dir/rustup"
                rustup completions bash cargo >> "$completion_dir/cargo"
                echo "Rustup completions for Bash added to: $completion_dir"
            fi
            ;;
        fish)
            local completion_dir="$HOME/.config/fish/completions"
            mkdir -p "$completion_dir"
            rustup completions fish > "$completion_dir/rustup.fish"
            echo "Rustup completions for Fish added to: $completion_dir"
            ;;
        zsh)
            local zfunc_dir="$HOME/.zfunc"
            mkdir -p "$zfunc_dir"
            rustup completions zsh > "$zfunc_dir/_rustup"
            rustup completions zsh cargo > "$zfunc_dir/_cargo" 
            # Ensure fpath is updated in .zshrc
            # if ! grep -q "fpath+=~/.zfunc" "$HOME/.zshrc"; then
            #     echo "fpath+=~/.zfunc" >> "$HOME/.zshrc"
            # fi
            if ! echo $fpath | grep -q ".zfunc" ; then
                fpath+=$zfunc_dir
                compinit
            fi

            echo "Rustup completions for Zsh added to: $zfunc_dir"
            ;;
        pwsh|powershell)
            local profile_path="$PROFILE"
            if [[ -z "$profile_path" ]]; then
                echo "PowerShell profile not found. Please configure it first."
                return 1
            fi
            rustup completions powershell >> "$profile_path.CurrentUserCurrentHost"
            echo "Rustup completions for PowerShell added to: $profile_path.CurrentUserCurrentHost"
            ;;
        *)
            echo "Unsupported shell: $shell"
            return 1
            ;;
    esac

    echo "Rustup completion script installation completed. Enjoy it!"
}

generate_rustup_completions


# add $HOME/.cargon/bin to PATH
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.cargo/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed rustc needs to be overridden
        export PATH="$HOME/.cargo/bin:$PATH"
        ;;
esac