#! bash oh-my-bash.module

source "$OSH/custom/themes/powerline-multiline-spack/powerline.base.sh"

function __powerline_last_status_prompt {
  (($1 != 0)) && _omb_util_print "$(set_color $LAST_STATUS_THEME_PROMPT_COLOR -) $1 $_omb_prompt_normal"
}

function __powerline_right_segment {
  local OLD_IFS=$IFS; IFS='|'
  local params=( $1 )
  IFS=$OLD_IFS
  local separator_char=$POWERLINE_RIGHT_SEPARATOR
  local padding=2
  local separator_color=""
  local text_color=${params[2]:-'-'}

  if ((SEGMENTS_AT_RIGHT == 0)); then
    separator_color=$(set_color ${params[1]} -)
  else
    separator_color=$(set_color ${params[1]} $LAST_SEGMENT_COLOR)
    ((padding += 1))
  fi
  RIGHT_PROMPT+="$separator_color$separator_char$_omb_prompt_normal$(set_color $text_color ${params[1]}) ${params[0]} $_omb_prompt_normal$(set_color - $COLOR)$_omb_prompt_normal"
  RIGHT_PROMPT_LENGTH=$((${#params[0]} + RIGHT_PROMPT_LENGTH + padding))
  LAST_SEGMENT_COLOR=${params[1]}
  ((SEGMENTS_AT_RIGHT += 1))
}

function __powerline_prompt_command {
  local last_status=$? ## always the first
  local separator_char=$POWERLINE_LEFT_SEPARATOR
  local move_cursor_rightmost='\033[500C'

  local LEFT_PROMPT=""
  local RIGHT_PROMPT=""
  local RIGHT_PROMPT_LENGTH=0
  local SEGMENTS_AT_LEFT=0
  local SEGMENTS_AT_RIGHT=0
  local LAST_SEGMENT_COLOR=""

  ## left prompt ##
  for segment in $POWERLINE_LEFT_PROMPT; do
    local info=$(__powerline_"$segment"_prompt)
    [[ $info ]] && __powerline_left_segment "$info"
  done
  [[ $LEFT_PROMPT ]] && LEFT_PROMPT+=$(set_color ${LAST_SEGMENT_COLOR} -)${separator_char}${_omb_prompt_normal}

  ## right prompt ##
  if [[ $POWERLINE_RIGHT_PROMPT ]]; then
    LEFT_PROMPT+=$move_cursor_rightmost
    for segment in $POWERLINE_RIGHT_PROMPT; do
      local info=$(__powerline_"$segment"_prompt)
      [[ $info ]] && __powerline_right_segment "$info"
    done
    LEFT_PROMPT+="\033[${RIGHT_PROMPT_LENGTH}D"
  fi

  PS1="$LEFT_PROMPT$RIGHT_PROMPT\n$(__powerline_last_status_prompt $last_status)$PROMPT_CHAR "
}
