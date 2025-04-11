# OK

Minimalistic tool to setup opinionated stack of other tools on Mac OS, Ubuntu and potentially other systems.

It is named after `... OK` message that appears when item is setup successfully.

## Description

I often struggle when I need to setup a new Mac with a set of instruments that I use daily at home or at work.
It takes time, effort and is just boring to repeat same things over an over again.
With OK I try to make this routine a bit less tedious.

OK is designed to run on a fresh Mac OS or Ubuntu system and will install the following tools:

- [brew](https://brew.sh/) (only on Mac OS)
- [git](https://git-scm.com/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [wezterm](https://wezfurlong.org/wezterm/index.html)
- [ghostty](https://ghostty.org/) (only MacOS at the moment)
- [zsh](https://www.zsh.org/)
- [oh my zsh](https://ohmyz.sh/)
- [fzf](https://github.com/junegunn/fzf)
- [Rust](https://www.rust-lang.org/tools/install)
- [zellij](https://zellij.dev/)
- [neovim](https://neovim.io/) with [lazyvim](https://www.lazyvim.org/) and some minimal plugins and themes that I use
- [ngrok](https://ngrok.com/)
- [Cascadia Code font](https://github.com/microsoft/cascadia-code)
- and related config files to setup above mentioned tools to the state I enjoy. **NOTE:** it will overwrite .zshrc file! So in case you have your own already - copy it somewhere before running OK.

OK avoids poluting screen with tons of output during installation. Instead it just returns a message like `Rust ... OK` when item installed successfully.
When setup is fully complete you will see `Installation ... OK` message as the last one. If you don't see it - then something went wrong and you can check what exactly in `/tmp/on-install.log`.

## Usage

Just open your default terminal and run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/Bor1s/ok/main/install.sh | bash
```

When OK is finished you can open Wezterm with zsh and enjoy nice Zellij session with Neovim.

## Testing

There are some test files that can be run via `bats`. I will add more tests in future:

```bash
bats test/darwin/check_and_install.bats
```

### Mac OS

Majority of testing (except some test running some tests with `bats`) is done manually. Run and see if any installation/runtime issues appear. Need to be careful to avoid overriding `.zshrc`.

### Ununtu

1. Build and run a container from `Dockerfile`: `docker build -t ubuntu-custom .`
2. Run container: `docker run --rm -it ubuntu-custom`
3. Run `sudo apt-get update`
4. Run `sudo apt-get upgrade`
5. Use `curl -fsSL https://raw.githubusercontent.com/Bor1s/ok/main/install.sh | bash` to run the full command to see if instalation works.

### Other OS

Work in progress...
