#!/usr/bin/env bats
# -*- mode: Shell-script;bash -*-

load helper

setup() {
    shared_setup
    REPO_ORIGIN=$(fake_repo)
    template_skeleton "$REPO_ORIGIN" plain "0.0.1"
    origin_repo "$REPO_ORIGIN"
    REPO=$(clone_repo $REPO_ORIGIN)
}

teardown() {
    shared_teardown
}

@test "set a plain version" {
    run avakas_wrapper set "$REPO" "0.0.2"
    [ "$status" -eq 0 ]
    scan_lines "Version set to 0.0.2" "${lines[@]}"
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.2" ]
}

@test "show a plain version" {
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.1" ]
}

@test "show a build version (git only in build component)" {
    run avakas_wrapper show "$REPO" --build
    [ "$status" -eq 0 ]
    REV=$(current_rev $REPO)
    [ "$output" == "0.0.1+${REV}" ]
}

@test "show a build version (git only + build number in build component)" {
    export BUILD_NUMBER=1
    run avakas_wrapper show "$REPO" --build
    unset BUILD_NUMBER
    [ "$status" -eq 0 ]
    REV=$(current_rev $REPO)
    [ "$output" == "0.0.1+${REV}.1" ]
}

@test "show a build version (git only in build component with preexisting build component)" {
    template_skeleton "$REPO" plain "0.0.1+1"
    run avakas_wrapper show "$REPO" --build
    echo "AAAA ${output}"
    [ "$status" -eq 0 ]
    REV=$(current_rev $REPO)
    [ "$output" == "0.0.1+1."$REV ]
}

@test "show a build version (git only in prerelease component)" {
    run avakas_wrapper show "$REPO" --pre-build
    [ "$status" -eq 0 ]
    REV=$(current_rev $REPO)
    [ "$output" == "0.0.1-${REV}" ]
}

@test "show a build version (git only in prerelease component with preexisting prerelease component)" {
    template_skeleton "$REPO" plain 0.0.1-1
    run avakas_wrapper show "$REPO" --pre-build
    [ "$status" -eq 0 ]
    echo "AAAA ${output}"
    REV=$(current_rev $REPO)
    [ "$output" == "0.0.1-1."$REV ]
}

@test "show a build version (git only + build number in prerelease component)" {
    export BUILD_NUMBER=1
    run avakas_wrapper show "$REPO" --pre-build
    unset BUILD_NUMBER
    [ "$status" -eq 0 ]
    REV=$(current_rev $REPO_ORIGIN)
    [ "$output" == "0.0.1-${REV}.1" ]
}

@test "bump a plain version - patch to patch" {
    run avakas_wrapper bump "$REPO" patch
    [ "$status" -eq 0 ]
    scan_lines "Version updated from 0.0.1 to 0.0.2" "${lines[@]}"
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.2" ]
}

@test "bump a plain version - patch to minor" {
    run avakas_wrapper bump "$REPO" minor
    [ "$status" -eq 0 ]
    scan_lines "Version updated from 0.0.1 to 0.1.0" "${lines[@]}"
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "0.1.0" ]
}

@test "bump a plain version - patch to major" {
    run avakas_wrapper bump "$REPO" major
    [ "$status" -eq 0 ]
    scan_lines "Version updated from 0.0.1 to 1.0.0"  "${lines[@]}"
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "1.0.0" ]
}

@test "bump a plain version - patch to prerelease" {
    run avakas_wrapper bump "$REPO" pre
    [ "$status" -eq 0 ]
    scan_lines "Version updated from 0.0.1 to 0.0.1-1"  "${lines[@]}"
    run avakas_wrapper show "$REPO"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.1-1" ]

}

@test "show a plain version - specified filename" {
    plain_version "$REPO" "0.0.1-1" "foo"
    run avakas_wrapper show "$REPO" --filename "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.1-1" ]
}

@test "set a plain version - specified filename" {
    plain_version "$REPO" "0.0.1-1" "foo"
    run avakas_wrapper set "$REPO" "0.0.2" --filename "foo"
    [ "$status" -eq 0 ]
    run avakas_wrapper show "$REPO" --filename "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.2" ]
}

@test "bump a plain version - patch->patch, specified filename" {
    plain_version "$REPO" "0.0.2" "foo"
    run avakas_wrapper bump "$REPO" "patch" --filename "foo"
    [ "$status" -eq 0 ]
    run avakas_wrapper show "$REPO" --filename "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "0.0.3" ]
}
