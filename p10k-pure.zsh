# Config file for Powerlevel10k with the style of Pure (https://github.com/sindresorhus/pure).
#
# Differences from Pure:
#
#   - Git:
#     - `@c4d3ec2c` instead of something like `v1.4.0~11` when in detached HEAD state.
#     - No automatic `git fetch` (the same as in Pure with `PURE_GIT_PULL=0`).
#
# Apart from the differences listed above, the replication of Pure prompt is exact. This includes
# even the questionable parts. For example, just like in Pure, there is no indication of Git status
# being stale; prompt symbol is the same in command, visual and overwrite vi modes; when prompt
# doesn't fit on one line, it wraps around with no attempt to shorten it.
#
# If you like the general style of Pure but not particularly attached to all its quirks, type
# `p10k configure` while having Powerlevel10k theme active and pick "Lean" style.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      # os_icon                 # os identifier
      dir                       # current directory
      vcs                       # git status
      context                   # user@host
      command_execution_time    # previous command duration
      newline                   # \n
      prompt_char               # prompt symbol
  )

  function prompt_asertoenv() {
    p10k segment -f '#f1c40f' -t "${ASERTO_ENV}"
  }

  function prompt_lver(){
    if [ -e $PWD/go.mod ]; then
      p10k segment -f '#25CCF7' -t " $(go version | cut -d' ' -f3| sed -e "s/^go//")"
    fi
    if [ -e $PWD/package.json ]; then
      p10k segment -f '#4cd137' -t " $(nvm current)"
    fi
    if [ -e $PWD/Gemfile ]; then
      p10k segment -f '#e84118' -t " $(rbenv global)"
   fi
  }

  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    lver                      # prompt language
    kubecontext
    asertoenv
  )

  # typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|mage'
  # typeset -g POWERLEVEL9K_KUBECONTEXT_SHORTEN=(gke eks)

  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=       # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add an empty line before each prompt except the first. This doesn't emulate the bug
  # in Pure that makes prompt drift down whenever you use the ALT-C binding from fzf or similar.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Green prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=002
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=001
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode is the same as in command mode. This is unlikely
  # to be desired by anyone but that's how Pure does it.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'
  # Prompt symbol in overwrite vi mode is the same as in command mode. This is unlikely
  # to be desired by anyone but that's how Pure does it.
  # typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=false

  # Blue current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=004

  # Context format when root: user@host. The first part white, the rest grey.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%7F%n%f%242F@%m%f'
  # Context format when not root: user@host. The whole thing grey.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%242F%n@%m%f'
  # Don't show context unless root or in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Don't show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Yellow previous command duration.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=$'\uE0A0 '

  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      # If P9K_CONTENT is not empty, use it. It's either "loading" or from vcs_info (not from
      # gitstatus plugin). VCS_STATUS_* parameters are not available in this case.
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      # Styling for up-to-date Git status.
      local       meta='%f'     # default foreground
      local      clean='%002F'  # cyan foreground
      local   modified='%003F'  # yellow foreground
      local  untracked='%006F'   # blue foreground
      local conflicted='%001F'  # red foreground
      # local vcs_color

      if [ ${VCS_STATUS_HAS_UNTRACKED} -eq 1 ]; then
        vcs_color=$untracked
      elif [ ${VCS_STATUS_HAS_STAGED} -eq 1 ]; then
        vcs_color=$modified
      elif [ ${VCS_STATUS_HAS_UNSTAGED} -eq 1 ]; then
        vcs_color=$modified
      else
        vcs_color=$clean
      fi
    else
      # Styling for incomplete and stale Git status.
      local       meta='%f'     # default foreground
      local      clean='%002F'   # green foreground
      local   modified='%214F'  # yellow foreground
      local  untracked='%006F'   # blue foreground
      local conflicted='%001F'  # red foreground
    fi

    local res
    local where  # branch name, tag or commit
    if [[ -n ${VCS_STATUS_REMOTE_NAME} ]]; then
      res+="${vcs_color}${POWERLEVEL9K_VCS_BRANCH_ICON}"
      where=${(V)VCS_STATUS_REMOTE_NAME}/${(V)VCS_STATUS_LOCAL_BRANCH}
    elif [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      res+="${vcs_color}${POWERLEVEL9K_VCS_BRANCH_ICON}"
      where=${(V)VCS_STATUS_LOCAL_BRANCH}
    elif [[ -n $VCS_STATUS_TAG ]]; then
      res+="${meta}#"
      where=${(V)VCS_STATUS_TAG}
    else
      res+="${meta}@"
      where=${VCS_STATUS_COMMIT[1,8]}
    fi

    # If local branch name or tag is at most 32 characters long, show it in full.
    # Otherwise show the first 12 … the last 12.

    (( $#where > 32 )) && where[13,-13]="…"
    res+="${vcs_color}${where//\%/%%}"  # escape %

    # Show tracking branch name if it differs from local branch.
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${vcs_color}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"  # escape %
    fi

    # ⇣42 if behind the remote.
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${vcs_color}⇣"
    # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${vcs_color}⇡"
    # *42 if have stashes.
    # (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    # 'merge' if the repo is in an unusual state.
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    # ~42 if have merge conflicts.
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    # +42 if have staged changes.
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    # !42 if have unstaged changes.
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    # ?42 if have untracked files. It's really a question mark, your font isn't broken.
    # See POWERLEVEL9K_VCS_UNTRACKED_ICON above if you want to use a different icon.
    # Remove the next line if you don't want to see untracked files at all.
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  # Disable the default Git status formatting.
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  # Install our own Git status formatter.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  # Enable counters for staged, unstaged, etc.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  # Icon color.
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=006
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=006
  # Custom icon.
  # typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # Custom prefix.
  # typeset -g POWERLEVEL9K_VCS_PREFIX=' '

  # Show status of repositories of these types. You can add svn and/or hg if you are
  # using them. If you do, your prompt may become slow even when your current directory
  # isn't in an svn or hg reposotiry.
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # These settings are used for respositories other than Git or when gitstatusd fails and
  # Powerlevel10k has to fall back to using vcs_info.
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=051
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=051
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178

  # Rvm color.
  typeset -g POWERLEVEL9K_RVM_FOREGROUND=001
  # Don't show @gemset at the end.
  typeset -g POWERLEVEL9K_RVM_SHOW_GEMSET=true
  # Don't show ruby- at the front.
  typeset -g POWERLEVEL9K_RVM_SHOW_PREFIX=false

  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
    '*eng*'           ASERTO_ENG
    '*prod*'  ASERTO_PROD
    '*opcr*'        OPCR
    '*'             DEFAULT)

  typeset -g POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='${P9K_KUBECONTEXT_NAME}'


  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND='fff'
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION='kubectx:'

  typeset -g POWERLEVEL9K_KUBECONTEXT_ASERTO_ENG_FOREGROUND='008'
  typeset -g POWERLEVEL9K_KUBECONTEXT_ASERTO_ENG_VISUAL_IDENTIFIER_EXPANSION='kubectx:'

  typeset -g POWERLEVEL9K_KUBECONTEXT_ASERTO_PROD_FOREGROUND='196'
  typeset -g POWERLEVEL9K_KUBECONTEXT_ASERTO_PROD_VISUAL_IDENTIFIER_EXPANSION='!!kubectx:'

  typeset -g POWERLEVEL9K_KUBECONTEXT_OPCR_FOREGROUND='#2ecc71'
  typeset -g POWERLEVEL9K_KUBECONTEXT_OPCR_VISUAL_IDENTIFIER_EXPANSION='kubectx:'



    # Defines character set used by powerlevel10k. It's best to let `p10k configure` set it for you.
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete

  # Connect left prompt lines with these symbols. You'll probably want to use the same color
  # as POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND below.
  # typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  # typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  # typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  # Connect right prompt lines with these symbols.
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX='%008F─╮'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX='%008F─┤'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX='%008F─╯'

    # Filler between left and right prompt on the first prompt line. You can set it to ' ', '·' or
  # '─'. The last two make it easier to see the alignment between left and right prompt and to
  # separate prompt from command output. You might want to set POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  # for more compact prompt if using this option.
  # typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  # typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  # typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
  # if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    # The color of the filler. You'll probably want to match the color of POWERLEVEL9K_MULTILINE
    # ornaments defined above.
    # typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=238
    # Start filler from the edge of the screen if there are no left segments on the first line.
    # typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    # End filler on the edge of the screen if there are no right segments on the first line.
    # typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  # fi

  # Separator between same-color segments on the left.
  # typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B5'
  # Separator between same-color segments on the right.
  # typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B7'
  # Separator between different-color segments on the left.
  # typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B4'
  # Separator between different-color segments on the right.
  # typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B6'
  # To remove a separator between two segments, add "_joined" to the second segment name.
  # For example: POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(os_icon context_joined)

  # # The right end of left prompt.
  # typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B4'
  # The left end of right prompt.
  # typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B6'
  # The left end of left prompt.
  # typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='░▒▓'
  # The right end of right prompt.
  # typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='▓▒░'
  # Left prompt terminator for lines without any segments.
  # typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  #################################[ os_icon: os identifier ]##################################
  # OS identifier color.
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7
  # Custom icon.
  # typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='⭐'

  #   ##################################[ dir: current directory ]##################################
  # # Current directory background color.
  # typeset -g POWERLEVEL9K_DIR_BACKGROUND=#ecf0f1
  # # Default current directory foreground color.
  # typeset -g POWERLEVEL9K_DIR_FOREGROUND=93
  # # If directory is too long, shorten some of its segments to the shortest possible unique
  # # prefix. The shortened directory can be tab-completed to the original.
  # # typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  # # Replace removed segment suffixes with this symbol.
  # typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  # # Color of the shortened directory segments.
  # typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=250
  # # Color of the anchor directory segments. Anchor segments are never shortened. The first
  # # segment is always an anchor.
  # typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=255
  # # Display anchor directory segments in bold.
  # typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

    #####################################[ vcs: git status ]######################################
  # Version control background colors.
  # typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=237
  # typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=237
  # typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=237
  # typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=237
  # typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=237

}

typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last

# Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
# For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
# can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
# really need it.
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

# If p10k is already loaded, reload configuration.
# This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
(( ! $+functions[p10k] )) || p10k reload

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
