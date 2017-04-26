#!/usr/bin/env bats

@test "invoking robot without arguments prints usage" {
  run robot
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "usage: robot COMMAND [arg...]" ]
}
