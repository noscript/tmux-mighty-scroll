CURRENT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

. "$CURRENT_DIR/scripts/helpers.sh"
. "$CURRENT_DIR/scripts/variables.sh"

case "$OSTYPE" in
  "darwin"*)
    set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck.sh"
    ;;
  *)
    if which cc >/dev/null 2>&1; then
      make -f "$CURRENT_DIR/Makefile" -C "$CURRENT_DIR" >/dev/null 2>&1
      set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck"
    else
      set_tmux_environment "PSCHECK" "$CURRENT_DIR/pscheck.sh"
    fi
    ;;
esac

set_tmux_environment "MIGHTY_SCROLL_INTERVAL" "$(get_tmux_option "$interval_option" "$interval_default")"
set_tmux_environment "MIGHTY_SCROLL_BY_LINE" "$(get_tmux_option "$by_line_option" "$by_line_default")"
set_tmux_environment "MIGHTY_SCROLL_BY_PAGE" "$(get_tmux_option "$by_page_option" "$by_page_default")"
set_tmux_environment "MIGHTY_SCROLL_PASS_THROUGH" "$(get_tmux_option "$pass_through_option" "$pass_through_default")"
set_tmux_environment "MIGHTY_SCROLL_FALLBACK_MODE" "$(get_tmux_option "$fallback_mode_option" "$fallback_mode_default")"

if [ "$(get_tmux_option "$select_pane_option" "$select_pane_default")" = "on" ]; then
  set_tmux_environment "MIGHTY_SCROLL_SELECT_PANE" "true"
else
  set_tmux_environment "MIGHTY_SCROLL_SELECT_PANE" "false"
fi

if [ "$(get_tmux_option "$show_indicator_option" "$show_indicator_default")" = "on" ]; then
  show_indicator_arg=''
else
  show_indicator_arg='-H'
fi

# FIXME: move to tmux.conf after https://github.com/tmux/tmux/issues/3791
tmux set-option -g command-alias[630] mighty_scroll_select_pane='if-shell "$MIGHTY_SCROLL_SELECT_PANE" {select-pane -t "{mouse}"}'
tmux set-option -g command-alias[631] mighty_scroll_with_interval='send-keys -t "{mouse}" -N $MIGHTY_SCROLL_INTERVAL'
tmux set-option -g command-alias[632] mighty_scroll_exit_mode_if_bottom='if-shell -F -t "{mouse}" "#{&&:#{pane_in_mode},#{==:#{scroll_position},0}}" {send-keys -t "{mouse}" -X cancel}'
tmux set-option -g command-alias[633] mighty_scroll_enter_copy_mode="copy-mode $show_indicator_arg -t '{mouse}'"

tmux source-file "$CURRENT_DIR/tmux.conf"
