# Fuzzy history list under the prompt. Down enters list, Up leaves it.
# Source after zsh-autosuggestions, this chains onto its widgets.
# Drawn via POSTDISPLAY because zle -M cannot render color.
zmodload zsh/parameter

typeset -g ARS_MAX_LINES=${ARS_MAX_LINES:-10}
typeset -g ARS_MARKER=${ARS_MARKER:-'❯ '}
# theme-agnostic on purpose, the kitty config toggles between light and dark
typeset -g ARS_ACTIVE_STYLE=${ARS_ACTIVE_STYLE:-standout}
typeset -g ARS_MATCH_STYLE=${ARS_MATCH_STYLE:-fg=green,bold}

typeset -g _ars_query=
typeset -g _ars_post=
typeset -gi _ars_index=0
typeset -ga _ars_matches=()
typeset -gi _ars_hist_count=0
typeset -ga _ars_hist_lines=()
typeset -ga _ars_pos=()
typeset -gA _ars_chain=()

# fzf does the matching, so its 'exact, ^prefix, suffix$, !negate syntax works
_ars_search() {
  emulate -L zsh
  _ars_matches=()
  if (( _ars_hist_count != $#history )); then
    _ars_hist_count=$#history
    _ars_hist_lines=()
    local k
    for k in ${(On)${(k)history}}; do
      _ars_hist_lines+=( "$history[$k]" )
    done
  fi
  (( $#_ars_hist_lines )) || return 0
  local out
  out=$(print -rN -- "$_ars_hist_lines[@]" | \
      command fzf --filter=$_ars_query --scheme=history --read0 --print0 2>/dev/null)
  [[ -n $out ]] || return 0
  _ars_matches=( "${(@0)out}" )
  _ars_matches=( "${(@)_ars_matches[1,ARS_MAX_LINES]}" )
}

# fzf reports no match offsets, so recompute them for highlighting
_ars_positions() {
  emulate -L zsh
  local hay=$1 term needle cmp_hay cmp_needle pre
  local -a out=()
  local -i i j start literal
  _ars_pos=()
  for term in ${=_ars_query}; do
    [[ -z $term || $term == \!* ]] && continue
    literal=0
    needle=$term
    case $needle in
      \'*) needle=${needle#\'}; literal=1 ;;
      \^*) needle=${needle#\^}; literal=1 ;;
    esac
    [[ $needle == *\$ && $needle != *\\\$ ]] && { needle=${needle%\$}; literal=1 }
    [[ -z $needle ]] && continue
    cmp_hay=$hay
    cmp_needle=$needle
    # smart case: an all-lowercase term matches case-insensitively
    if [[ $needle == ${needle:l} ]]; then
      cmp_hay=${hay:l}
      cmp_needle=${needle:l}
    fi
    if (( literal )); then
      pre=${cmp_hay%%${~:-${(b)cmp_needle}}*}
      [[ $pre == $cmp_hay ]] && continue
      start=$#pre
      for (( i = 1; i <= $#needle; i++ )); do
        out+=( $(( start + i )) )
      done
      continue
    fi
    local -a fwd=()
    j=1
    for (( i = 1; i <= $#cmp_hay && j <= $#cmp_needle; i++ )); do
      if [[ $cmp_hay[i] == $cmp_needle[j] ]]; then
        fwd+=( $i )
        (( j++ ))
      fi
    done
    (( j > $#cmp_needle )) || continue
    j=$#cmp_needle
    for (( i = $fwd[-1]; i >= 1 && j >= 1; i-- )); do
      if [[ $cmp_hay[i] == $cmp_needle[j] ]]; then
        out+=( $i )
        (( j-- ))
      fi
    done
  done
  _ars_pos=( ${(nou)out} )
}

_ars_clear_display() {
  region_highlight=( "${(@)region_highlight:#*memo=auto-reverse-search*}" )
  if [[ -n $_ars_post && $POSTDISPLAY == *${_ars_post} ]]; then
    POSTDISPLAY=${POSTDISPLAY%${_ars_post}}
  fi
  _ars_post=
}

_ars_render() {
  emulate -L zsh
  _ars_clear_display
  (( $#_ars_matches )) || return 0

  local text= disp marker style
  local -a positions=()
  local -i i p base row_start disp_start run_start run_end width
  width=$(( COLUMNS - 4 ))
  (( width < 20 )) && width=20
  base=$(( $#BUFFER + $#POSTDISPLAY ))

  for (( i = 1; i <= $#_ars_matches; i++ )); do
    disp=${_ars_matches[i]//$'\n'/ }
    (( $#disp > width )) && disp="${disp[1,width-1]}…"
    if (( i == _ars_index )); then
      marker=$ARS_MARKER
    else
      marker=${(l:$#ARS_MARKER:: :)}
    fi
    row_start=$(( base + $#text + 1 ))
    disp_start=$(( row_start + $#marker ))
    text+=$'\n'${marker}${disp}

    if (( i == _ars_index )); then
      region_highlight+=(
        "$row_start $(( disp_start + $#disp )) $ARS_ACTIVE_STYLE memo=auto-reverse-search" )
      style="$ARS_MATCH_STYLE,$ARS_ACTIVE_STYLE"
    else
      style=$ARS_MATCH_STYLE
    fi

    _ars_positions "$disp"
    positions=( $_ars_pos )
    (( $#positions )) || continue
    # merge neighbours so a matched run becomes one highlight entry
    run_start=$positions[1]
    run_end=$positions[1]
    for p in ${positions[2,-1]} 0; do
      if (( p == run_end + 1 )); then
        run_end=$p
        continue
      fi
      region_highlight+=(
        "$(( disp_start + run_start - 1 )) $(( disp_start + run_end )) $style memo=auto-reverse-search" )
      run_start=$p
      run_end=$p
    done
  done

  _ars_post=$text
  POSTDISPLAY+=$text
}

# a picked history line is complete, so drop the inline suggestion
_ars_drop_suggestion() {
  (( $+functions[_zsh_autosuggest_highlight_reset] )) && _zsh_autosuggest_highlight_reset
  _ars_clear_display
  POSTDISPLAY=
}

_ars_update() {
  [[ $CONTEXT == start ]] || return 0
  _ars_index=0
  _ars_query=$BUFFER
  if [[ -z $_ars_query ]]; then
    _ars_matches=()
  else
    _ars_search
  fi
  _ars_render
}

# name is passed in, $WIDGET lies when other plugins call zle without -w
_ars_dispatch() {
  local w=$1
  shift
  typeset -g _ars_busy=1
  zle ${_ars_chain[$w]} -- "$@"
  local -i ret=$?
  _ars_busy=
  _ars_update
  return ret
}

_ars_select() {
  _ars_drop_suggestion
  BUFFER=$_ars_matches[_ars_index]
  CURSOR=$#BUFFER
  _ars_render
}

ars-down() {
  if (( _ars_index == 0 )); then
    if (( $#_ars_matches )); then
      _ars_index=1
      _ars_select
    else
      zle .down-line-or-history
    fi
  elif (( _ars_index < $#_ars_matches )); then
    (( _ars_index++ ))
    _ars_select
  fi
}

ars-up() {
  if (( _ars_index > 1 )); then
    (( _ars_index-- ))
    _ars_select
  elif (( _ars_index == 1 )); then
    _ars_index=0
    _ars_drop_suggestion
    BUFFER=$_ars_query
    CURSOR=$#BUFFER
    _ars_render
  else
    # not .history-search-backward, it loses continuation state when called here
    zle .up-line-or-history
    _ars_matches=()
    _ars_query=
    _ars_render
  fi
}

_ars_line_init() {
  _ars_index=0
  _ars_query=
  _ars_post=
  _ars_matches=()
  return 0
}

_ars_line_finish() {
  _ars_clear_display
  return 0
}

zle -N ars-up
zle -N ars-down
bindkey '^[[A' ars-up '^[OA' ars-up
bindkey '^[[B' ars-down '^[OB' ars-down
[[ -n $terminfo[kcuu1] ]] && bindkey $terminfo[kcuu1] ars-up
[[ -n $terminfo[kcud1] ]] && bindkey $terminfo[kcud1] ars-down

_ars_bind_widgets() {
  local w fn
  for w in self-insert backward-delete-char delete-char backward-kill-word \
      kill-word kill-line kill-whole-line backward-kill-line yank yank-pop \
      undo redo bracketed-paste; do
    [[ -v widgets[$w] ]] || continue
    case ${widgets[$w]} in
      user:_ars_widget_*) continue ;;
      user:*)
        zle -N _ars_orig-$w ${widgets[$w]#*:}
        _ars_chain[$w]=_ars_orig-$w
        ;;
      completion:*)
        eval "zle -C _ars_orig-${(q)w} ${${(s.:.)widgets[$w]}[2,3]}"
        _ars_chain[$w]=_ars_orig-$w
        ;;
      *) _ars_chain[$w]=.$w ;;
    esac
    fn=_ars_widget_${w//-/_}
    eval "$fn() { _ars_dispatch ${(q)w} \"\$@\" }"
    zle -N $w $fn
  done
}

# autosuggestions binds on first prompt, so bind after it or it wraps us
_ars_start() {
  _ars_bind_widgets
  # runs first in every autosuggestions widget, so the list is out of
  # POSTDISPLAY before it dims or accepts what it finds there
  if (( $+functions[_zsh_autosuggest_highlight_reset] && ! $+functions[_ars_orig_hl_reset] )); then
    functions[_ars_orig_hl_reset]=$functions[_zsh_autosuggest_highlight_reset]
    _zsh_autosuggest_highlight_reset() {
      _ars_orig_hl_reset "$@"
      _ars_clear_display
    }
  fi
  # its async reply repaints POSTDISPLAY after our widget returned, so redraw
  if (( $+functions[_zsh_autosuggest_highlight_apply] && ! $+functions[_ars_orig_hl_apply] )); then
    functions[_ars_orig_hl_apply]=$functions[_zsh_autosuggest_highlight_apply]
    _zsh_autosuggest_highlight_apply() {
      _ars_orig_hl_apply "$@"
      [[ -n $_ars_busy ]] || _ars_render
    }
  fi
  add-zsh-hook -d precmd _ars_start
  unfunction _ars_start
}

autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook precmd _ars_start
add-zle-hook-widget line-init _ars_line_init
add-zle-hook-widget line-finish _ars_line_finish
