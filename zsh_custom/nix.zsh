# nix backports
for profile in ${(z)NIX_PROFILES}; do
    if [[ -e "$profile/share/zsh" ]] then
        fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
    fi
done

if [[ ! -z ${(z)NIX_USER_PROFILE_DIR} ]] && [[ -e $NIX_USER_PROFILE_DIR/home-manager/home-path/share/zsh ]]; then
    zshare=$NIX_USER_PROFILE_DIR/home-manager/home-path/share/zsh
    fpath+=($zshare/site-functions $zshare/$ZSH_VERSION/functions $zshare/vendor-completions)
fi