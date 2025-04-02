#!/usr/bin/env bash

# Boolector: Satisfiablity Modulo Theories (SMT) solver.
#
# Copyright (C) 2007-2021 by the authors listed in the AUTHORS file.
#
# This file is part of Boolector.
# See COPYING for more information on using this software.
#

set -e -o pipefail

source "$(dirname "$0")/setup-utils.sh"

BTOR2TOOLS_DIR=${DEPS_DIR}/btor2tools
COMMIT_ID="e24a9f9c61881cdfd80f6038cae3b484ac094b34"

download_github "rafaelsamenezes/btor2tools" "$COMMIT_ID" "$BTOR2TOOLS_DIR"
cd "${BTOR2TOOLS_DIR}"

if is_windows; then
  component="Btor2Tools"
  last_patch_date="20190110"
  test_apply_patch "${component}" "${last_patch_date}"
fi

if is_macos; then
   mkdir build
   pushd build
   cmake .. -DBUILD_SHARED_LIBS=OFF -DCMAKE_OSX_ARCHITECTURES='x86_64;arm64'
   make -j${NPROC}
   popd
else
  CFLAGS="-fPIC" ./configure.sh --static
  pushd build
  make -j${NPROC}
  popd
fi

install_lib build/lib/libbtor2parser.a
install_include src/btor2parser/btor2parser.h
