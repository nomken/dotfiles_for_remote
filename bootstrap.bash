#!/bin/bash

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

# http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# http://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash

declare -r SCRIPT_DIR="$( cd $(dirname $0) ; pwd -P )"
# http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself

declare -r NC='\033[0m'

declare -rA COLORS_ENV_HASH=(
  ['prod']='\033[0;31m'
  ['stg']='\033[0;34m'
  ['dev']='\033[0;33m'
  ['lab']='\033[0;32m'
)

declare -rA COLORS_HASH=(
  ['Black']='\033[0;30m'
  ['Red']='\033[0;31m'
  ['Green']='\033[0;32m'
  ['Brown/Orange']='\033[0;33m'
  ['Blue']='\033[0;34m'
  ['Purple']='\033[0;35m'
  ['Cyan']='\033[0;36m'
  ['Light Gray']='\033[0;37m'

  ['Dark Gray']='\033[1;30m'
  ['Light Red']='\033[1;31m'
  ['Light Green']='\033[1;32m'
  ['Yellow']='\033[1;33m'
  ['Light Blue']='\033[1;34m'
  ['Light Purple']='\033[1;35m'
  ['Light Cyan']='\033[1;36m'
  ['White']='\033[1;37m'

  ['No Color']='\033[0m'
)

select_env_color() {
  local -i index=0
  local -a colors_env_array=("${!COLORS_ENV_HASH[@]}")
  local -i i=0

  for color in "${!COLORS_ENV_HASH[@]}"; do
    echo -e "$i : ${COLORS_ENV_HASH["$color"]}$color${NC}"
    ((i++))
  done
  echo "$i : others"
  read -p "Which env color do you want? [0]: " index

  if [[ index -eq "${#colors_env_array[@]}" ]]; then
    echo ""
    return 1
  fi

  local key=${colors_env_array[index]}
  COLOR_CODE="${COLORS_ENV_HASH["$key"]}"
  echo -en "${COLOR_CODE}$index : $key => "
  echo "${COLORS_ENV_HASH["$key"]}"
  echo -e "${NC}"
 }

select_color() {
  local -i index=0
  local -a colors_array=("${!COLORS_HASH[@]}")
  local -i i=0

  for color in "${!COLORS_HASH[@]}"; do
    echo -e "$i : ${COLORS_HASH["$color"]}$color${NC}"
    ((i++))
  done
  read -p "Which env color do you want? [0]: " index

  local key=${colors_array[index]}
  COLOR_CODE="${COLORS_HASH["$key"]}"
  echo -en "${COLOR_CODE}$index : $key => "
  echo "${COLORS_HASH["$key"]}${NC}"
  echo -e "${NC}"
}

main() {
  COLOR_CODE=""
  select_env_color
  if [[ $? -ne 0 ]]; then
    select_color
  fi
  COLOR_CODE="\\$COLOR_CODE" # escaping with \\

  echo "Creating bash/.bashrc_misc from template in $SCRIPT_DIR"
  [[ -d $SCRIPT_DIR/bash ]] ||  mkdir $SCRIPT_DIR/bash
  sed -e s/\$COLOR_CODE/"$COLOR_CODE"/g $SCRIPT_DIR/bashrc_template.bash > $SCRIPT_DIR/bash/.bashrc_misc 
  echo "created."
  echo ""

  echo "Adding command in $HOME/.bashrc"
  if [[ $(grep ".bashrc_misc" $HOME/.bashrc | wc -l) -ne 0 ]]; then
    echo "$SCRIPT_DIR/bash/.bashrc_misc already exists. skipped."
  else
    read -p "add a command to use this script everytime? [yN]: " yn || echo
    [[ $yn =~ Y|y|Yes ]] && {
      echo "" >> $HOME/.bashrc
      echo "# for custmized bash prompt like coloring..." >> $HOME/.bashrc
      echo "[[ -s '$SCRIPT_DIR/bash/.bashrc_misc' ]] && source '$SCRIPT_DIR/bash/.bashrc_misc'" >> $HOME/.bashrc
      echo "added."
    } || echo "skipped."
  fi
  echo ""

}

main
echo "do '$ source ~/.bashrc' to apply this change now."
echo "finished."
exit 0

