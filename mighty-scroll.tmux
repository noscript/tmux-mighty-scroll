CURRENT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

. "$CURRENT_DIR/scripts/helpers.sh"
. "$CURRENT_DIR/scripts/variables.sh"

if which cc >/dev/null 2>&1; then
  make -f "$CURRENT_DIR/Makefile" -C "$CURRENT_DIR" >/dev/null 2>&1
  set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck"
else
  set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck.sh"
fi

set_tmux_environment "MIGHTY_SCROLL_INTERVAL" "$(get_tmux_option "$interval_option" "$interval_default")"
set_tmux_environment "MIGHTY_SCROLL_BY_LINE" "$(get_tmux_option "$by_line_option" "$by_line_default")"
set_tmux_environment "MIGHTY_SCROLL_BY_PAGE" "$(get_tmux_option "$by_page_option" "$by_page_default")"
set_tmux_environment "MIGHTY_SCROLL_FALLBACK_MODE" "$(get_tmux_option "$fallback_mode_option" "$fallback_mode_default")"

if [ "$(get_tmux_option "$select_pane_option" "$select_pane_default")" = "on" ]; then
  set_tmux_environment "MIGHTY_SCROLL_SELECT_PANE" "true"
else
  set_tmux_environment "MIGHTY_SCROLL_SELECT_PANE" "false"
fi

tmux source-file "$CURRENT_DIR/tmux.conf"
