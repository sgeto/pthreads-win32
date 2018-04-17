#!bin/sh

set -ex

# config.h is weird. It breaks MSVC builds after being recreated during
# configure. I guess PTHREADS-WIN32 developers' forgot to regenerate it
# after modification configure.ac.
# To avoid overwriting it, this script will go for an
# out-of-source build (until someone figures this out...).