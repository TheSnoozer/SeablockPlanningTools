data:extend{
  {
    type = "bool-setting",
    name = "spt-lawful-good-inserters",
    setting_type = "runtime-per-user",
    default_value = false,
  },
  {
    type = "int-setting",
    name = "spt-small-range-optimizer",
    setting_type = "runtime-per-user",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 50,
  },
  {
    type = "int-setting",
    name = "spt-default-range-optimizer",
    setting_type = "runtime-per-user",
    default_value = 15,
    minimum_value = 1,
    maximum_value = 50,
  },
  {
    type = "int-setting",
    name = "spt-large-range-optimizer",
    setting_type = "runtime-per-user",
    default_value = 30,
    minimum_value = 1,
    maximum_value = 50,
  },
}