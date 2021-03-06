#!/bin/bash

set -e

source $PWD/ext/bash-tap/bash-tap
# plan tests 2

GIT_HUB_TEST_MODE="1"
GIT_HUB_TEST_COMMAND="1"
GIT_HUB_CONFIG=$PWD/test/githubconfig

source $PWD/lib/git-hub
assert-env

foo_git=./test/foo.git
fake_token=0123456789ABCDEF

test_command() {
    get-options $@
    "github-$command"
    local curl="${curl_command[@]}"
    local label="$@"
    [ -n "$GIT_DIR" ] && label=$(printf "%-40s %s" "$label" "($GIT_DIR)")
    is "$curl" "$expected" "$label"
}

expect() {
    local action="$1"; shift
    suffix=${@/AUTH/--header Authorization: token $fake_token}
    expected="curl --request $action https://api.github.com$suffix"
}

diag "Test all the permutations of command and arguments and environments"

#----------------------------------------------------------------------------
diag "Test 'user' commands:"

expect GET /users/tommy
GIT_DIR=not-in-git-dir \
test_command "user"

expect GET /users/geraldo
GIT_DIR=not-in-git-dir \
test_command "user geraldo"

expect GET /users/ricardo
GIT_DIR=$foo_git \
test_command "user"

expect GET /users/geraldo
GIT_DIR=$foo_git \
test_command "user geraldo"

#----------------------------------------------------------------------------
diag "Test 'user-edit' commands:"

expect PATCH /user -d '{"name":"Tomster"}' AUTH
GIT_DIR=not-in-git-dir \
test_command 'user-edit name Tomster'

#----------------------------------------------------------------------------
diag "Test 'repo' commands:"

expect 'GET' "/repos/tommy/xyz"
GIT_DIR=not-in-git-dir \
test_command "repo xyz"

expect 'GET' "/repos/ricardo/foo"
GIT_DIR=$foo_git \
test_command "repo"

expect 'GET' "/repos/geraldo/rivets"
test_command "repo geraldo/rivets"

done_testing
