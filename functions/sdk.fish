# --------------------------------------------------
# main
# --------------------------------------------------
function sdk
  set DEFAULT_IFS $IFS
  set IFS
  switch $argv[1]
    case 'default'
      __sdk_default $argv[2..-1]
    case 'install'
      __sdk_install $argv[2..-1]
    case 'uninstall'
      __sdk_uninstall $argv[2..-1]
    case 'use'
      __sdk_use $argv[2..-1]
    case '*'
      __sdk $argv
  end
  set IFS $DEFAULT_IFS
end


# --------------------------------------------------
# subcommands
# --------------------------------------------------
function __sdk_default
  set candidate $argv[1]
  switch $candidate
    case 'java'
      set subjects (__sdk_list_installed_java)
    case ''
      return
    case '*'
      set subjects (__sdk_list_installed_something $candidate)
  end

  if test -z "$subjects"
    return
  end

  set selected (echo -e $subjects | fzf)

  if test -z "$selected"
    return
  end

  __sdk default $candidate $selected
end

function __sdk_install
  set candidate $argv[1]
  switch $candidate
    case 'java'
      set subjects (__sdk_list_not_installed_java)
    case ''
      return
    case '*'
      set subjects (__sdk_list_not_installed_something $candidate)
  end

  if test -z "$subjects"
    return
  end

  set selected (echo -e $subjects | fzf)

  if test -z "$selected"
    return
  end

  __sdk install $candidate $selected
end

function __sdk_uninstall
  set candidate $argv[1]
  switch $candidate
    case 'java'
      set subjects (__sdk_list_installed_java)
    case ''
      return
    case '*'
      set subjects (__sdk_list_installed_something $candidate)
  end

  if test -z "$subjects"
    return
  end

  set selected (echo -e $subjects | fzf)

  if test -z "$selected"
    return
  end

  __sdk uninstall $candidate $selected
end

function __sdk_use
  set candidate $argv[1]
  if test (count $argv) -ge 2
    set selected $argv[2]
  end

  if not set -q selected
    switch $candidate
      case 'java'
        set subjects (__sdk_list_installed_java)
      case ''
        return
      case '*'
        set subjects (__sdk_list_installed_something $candidate)
    end

    if test -z "$subjects"
      return
    end

    set selected (echo -e $subjects | fzf)

    if test -z "$selected"
      return
    end
  end

  set -l base "$HOME/.sdkman/candidates/$candidate"
  __sdk_remove_path "$base/*"
  __sdk_add_path "$base/$selected/bin"

  echo -e "\033[0;92m\033[1mUsing $candidate version $selected in this shell.\033[0m\033[0;0m"
end


# --------------------------------------------------
# sdk listener
# --------------------------------------------------
function __sdk_auto_env --on-variable PWD
  set config_path $HOME/.sdkman/etc/config

  if not test -e $config_path
    return
  end

  if not cat $config_path | string match -r '.*sdkman_auto_env_fish=true.*' > /dev/null
    return
  end

  set sdk_java_dir "$HOME/.sdkman/candidates/java"
  set current_dir  $PWD
  while string match -r "^$HOME.*" $current_dir > /dev/null;
    if not test -e $current_dir/.sdkmanrc
      set current_dir (dirname $current_dir)
      continue
    end

    set jdk_version (cat $current_dir/.sdkmanrc | grep -v -e '^#.*' | grep -e 'java=.*' | awk -F= '{print $2}')
    if test -z $jdk_version
      break
    end

    if string match -r ".*$sdk_java_dir/$jdk_version/bin.*" $PATH > /dev/null
      return
    end

    sdk use java $jdk_version
    return
  end

  __sdk_remove_path "$sdk_java_dir/*"
end


# --------------------------------------------------
# sdk utilities
# --------------------------------------------------
function __sdk
  bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk $argv"
end

function __sdk_list_all_java
  if set -l rs (__sdk list java)
    echo $rs \
      | sed -n -E -e '/^-+/,/^=+/p' \
      | sed -e '/^[-=]\+/d' -e 's/ //g' -e 's/installed/\*/g' \
      | awk -F '|' '{printf "%1s %s\n", $5, $6}' \
      | sed -e '/^ *$/d' \
      | sort -r
  else
    echo $rs > /dev/stderr
  end
end

function __sdk_list_installed_java
  __sdk_list_all_java \
    | grep -e '^\*' \
    | sed -e 's/[* ]*//g'
end

function __sdk_list_not_installed_java
  __sdk_list_all_java \
    | grep -v -e '^\*'
end

function __sdk_list_all_something
  if set -l rs (__sdk list $argv[1])
    echo $rs \
      | sed -z -E -e 's/[\n>]//g' -e 's/^.*=+([0-9rc.>* \-]+)=+.*$/\1/g' -e 's/ {2,}/\n/g' \
      | sed -e '/^$/d' \
      | sort -r
  else
    echo $rs > /dev/stderr
  end
end

function __sdk_list_installed_something
  __sdk_list_all_something $argv[1] \
    | grep -e '^\*' \
    | sed -e 's/[* ]*//g'
end

function __sdk_list_not_installed_something
  __sdk_list_all_something $argv[1] \
    | grep -v -e '^\*'
end


# --------------------------------------------------
# utilities
# --------------------------------------------------
function __sdk_add_path
  set newer $argv[1]
  if test -e $newer; and not contains $newer $PATH
    set -x PATH $newer $PATH
  end
end

function __sdk_remove_path
  for candidate in $PATH
    if string match -r '.*current.*' $candidate > /dev/null; or not string match -r $argv[1] $candidate > /dev/null
      set newer $newer $candidate
    end
  end
  set -x PATH $newer
end

