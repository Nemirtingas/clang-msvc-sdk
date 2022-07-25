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

function is_bin_in_path
{
  if [[ -n $ZSH_VERSION ]]; then
    builtin whence -p "$1" &> /dev/null
  else  # bash:
    builtin type -P "$1" &> /dev/null
  fi
}

echo "${0}: ${@}"

if [ ! -z "${LLVM_VER}" ] && is_bin_in_path "llvm-mt-${LLVM_VER}"; then
  LLVM_MT="llvm-mt-${LLVM_VER}"
elif is_bin_in_path "llvm-mt"; then
  LLVM_MT="llvm-mt"
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
