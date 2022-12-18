# Tmux Mighty Scroll

Ultimate solution to enable seamless mouse scroll in tmux.

When no process running, it will scroll over the pane content. Otherwise,
depending on process name, it will pass <kbd>↑</kbd> / <kbd>↓</kbd> or
<kbd>Page Up</kbd> / <kbd>Page Down</kbd> keys.

## Features

* Works in scenarios like `$ git log`, `$ find | less`, etc.
* Works in other applications like `fzf`, `mc`, `man`, `ranger`, `vim`, etc.
* Works with nested environments like `chroot`.
* Starts copy-mode automatically when no process running.

## Limitations

Does not work in panes with open remote connection, since there is no way to
relay back to tmux which processes are running in remote shell.
See `@mighty-scroll-fallback-mode`.

## Requirements

* Mouse mode enabled (`set -g mouse on`).
* C compiler (Linux only. Optional, but highly recommended).

## Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add the plugin to the list of TPM plugins in `.tmux.conf`:

```
set -g @plugin 'noscript/tmux-mighty-scroll'
```

Hit `prefix + I` to fetch the plugin and source it.

## Manual Installation

Clone the repo:

```
$ git clone https://github.com/noscript/tmux-mighty-scroll ~/clone/path
```

Add this line to the bottom of `.tmux.conf`:

```
run '~/clone/path/mighty-scroll.tmux'
```

Reload tmux environment:

```
$ tmux source ~/.tmux.conf
```

## Configuration

|Option|Default value|Supported values|Description|
|---|---|---|---|
|`@mighty-scroll-interval`|`2`|Number|How many lines to scroll in `by-line` and `history` modes.|
|`@mighty-scroll-select-pane`|`on`|`on`, `off`|If enabled, the pane being scrolled becomes automatically selected.|
|`@mighty-scroll-by-line`|`'man less pager fzf'`|List|Space separated list of processes that will be scrolled  by line.|
|`@mighty-scroll-by-page`|`'irssi vim vi'`|List|Space separated list of processes that will be scrolled by page.|
|`@mighty-scroll-fallback-mode`|`'history'`|`'history'`, `'by-line'`, `'by-page'`|Scroll mode when in alternate screen but the process didn't match `by-line` and `by-page` lists from above.|

Scrolling modes:

* `history` - enter copy mode and scroll over the pane content by line.
* `by-line` - scroll by line, the running process will receive <kbd>↑</kbd> / <kbd>↓</kbd> keys.
* `by-page` - scroll by page, the running process will receive <kbd>Page Up</kbd> / <kbd>Page Down</kbd> keys.

Example configuration:

```
set -g mouse on
set -g @mighty-scroll-interval 3
set -g @mighty-scroll-by-line 'man fzf'
set -g @mighty-scroll-select-pane off
```

## Performance caveats

On Linux, make sure to have a C compiler (`gcc`, `clang`) available (check with
`$ cc -v`), otherwise a Shell implementation of the process checker will be
used, which is about 400% slower!

On macOS there is only a Shell implementation of the process checker at the moment.

## License
[MIT](LICENSE.MIT)
