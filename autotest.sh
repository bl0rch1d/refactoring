#!/bin/bash
#===============================================================================
#          FILE:  autotest.sh
#
#         USAGE:  ./autotest.sh
#
#   DESCRIPTION:  Automated ruby code checker and spec runner. Just add this
#                 file to your ruby project folder and run.
#
#       OPTIONS:  You can add/remove gems if you wish.
#
#        AUTHOR:  bl0rch1d
#       VERSION:  0.2.1
#===============================================================================


FILES_TO_WATCH='./**/**/*.rb'

current_files_hash=()
new_files_hash=()

get_mdsum() {
  sudo md5sum $1
}

collect_hashes(){
  local ary=()

  for file in $FILES_TO_WATCH; do
    local ary+=($(get_mdsum $file))
  done

  eval $1="'${ary[@]}'"
}

start(){
  while true; do
    collect_hashes current_files_hash

    while true; do
      collect_hashes new_files_hash

      if [ "${current_files_hash[*]}" != "${new_files_hash[*]}" ]; then
        
        echo "========== FASTERER =========="
        bundle exec fasterer

        echo "========== RUBOCOP =========="
        bundle exec rubocop

        echo "=========== RSPEC ==========="
        bundle exec rspec

        # Add more gems here
        # Example: bundle exec <gemname>
        
        break
      fi

      sleep 1
    done
  done
}

start
