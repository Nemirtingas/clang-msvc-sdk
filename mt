#! /bin/bash

#dummy_manifest="<?xml version=\"1.0\" standalone=\"yes\"?>
#<assembly xmlns=\"urn:schemas-microsoft-com:asm.v1\"
#          manifestVersion=\"1.0\">
#  <trustInfo>
#    <security>
#      <requestedPrivileges>
#         <requestedExecutionLevel level='asInvoker' uiAccess='false'/>
#      </requestedPrivileges>
#    </security>
#  </trustInfo>
#</assembly>"

function which
{
  arg=$1
  IFS=':' read -ra paths <<< "$PATH"
  for p in "${paths[@]}"; do
    if [ -x "$p/$arg" ]; then
      echo "$p/$arg"
      break
    fi
  done
}

echo "${0}: ${@}"

LLVM_MT="$(which "llvm-mt-${LLVM_VER}")"
if [ -z "$LLVM_MT" ]; then
  LLVM_MT="$(which "llvm-mt")"
fi

if [ -z "$LLVM_MT" ]; then
  echo "Can't find llvm-mt, skipping manifest."
  exit 0
fi

output="$("$LLVM_MT" "${@}" 2>&1)"
res=$?

if [ "$res" -ne 0 ]; then
  if echo "$output" | grep -q "no libxml2"; then
    echo "llvm-mt not compiled with libxml2, skipping manifest."
    exit 0
  fi
fi

echo "$output"
exit "$res"
