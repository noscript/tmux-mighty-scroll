CURRENT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

. "$CURRENT_DIR/scripts/helpers.sh"
. "$CURRENT_DIR/scripts/variables.sh"

case "$OSTYPE" in
  "darwin"*)
    set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck.sh"
    ;;
  *)
    CC="${CC:-cc}"
    if which "$CC" >/dev/null 2>&1; then
      SRC="$CURRENT_DIR/pscheck.c"
      OUT="$CURRENT_DIR/pscheck"
      if [ ! -e "$OUT" ] || [ "$SRC" -nt "$OUT" ]; then
        CFLAGS="-O3 $CFLAGS"
        "$CC" -Wall -Wextra -Werror -Wconversion -pedantic -std=c99 $CFLAGS "$SRC" -o "$OUT" 2>&1
      fi
      set_tmux_environment "PSCHECK" "$OUT"
    else
      set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck.sh"
    fi
    ;;
esac

scroll_interval="$(get_tmux_option "$interval_option" "$interval_default")"

set_tmux_environment "MIGHTY_SCROLL_BY_LINE" "$(get_tmux_option "$by_line_option" "$by_line_default")"
set_tmux_environment "MIGHTY_SCROLL_BY_PAGE" "$(get_tmux_option "$by_page_option" "$by_page_default")"
set_tmux_environment "MIGHTY_SCROLL_PASS_THROUGH" "$(get_tmux_option "$pass_through_option" "$pass_through_default")"
set_tmux_environment "MIGHTY_SCROLL_FALLBACK_MODE" "$(get_tmux_option "$fallback_mode_option" "$fallback_mode_default")"

if [ "$(get_tmux_option "$select_pane_option" "$select_pane_default")" = "on" ]; then
  select_pane_cmd='select-pane -t "{mouse}"'
else
  select_pane_cmd=''
fi

if [ "$(get_tmux_option "$show_indicator_option" "$show_indicator_default")" = "on" ]; then
  show_indicator_arg=''
else
  show_indicator_arg='-H'
fi

# FIXME: move to tmux.conf after https://github.com/tmux/tmux/issues/3791
tmux set-option -g command-alias[630] mighty_scroll_select_pane="$select_pane_cmd"
tmux set-option -g command-alias[631] mighty_scroll_with_interval="send-keys -t '{mouse}' -N $scroll_interval"
tmux set-option -g command-alias[632] mighty_scroll_exit_mode_if_bottom='if-shell -F -t "{mouse}" "#{&&:#{pane_in_mode},#{==:#{scroll_position},0}}" {send-keys -t "{mouse}" -X cancel}'
tmux set-option -g command-alias[633] mighty_scroll_enter_copy_mode="copy-mode $show_indicator_arg -t '{mouse}'"

tmux source-file "$CURRENT_DIR/tmux.conf"
