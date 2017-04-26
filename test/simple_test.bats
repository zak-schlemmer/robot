#!/usr/bin/env bats

@test "invoking robot without arguments prints usage" {
  run robot
  [ "$status" -eq 1 ]
  #[ "${lines[2]}" = "robot COMMAND [arg...]" ]
}
