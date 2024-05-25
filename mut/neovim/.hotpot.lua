return {
  build = {
    {verbose = true},
    {"fnl/**/*macro*.fnl", false}, -- dont compile macro files
    {"init.fnl", true},
    {"fnl/conf/**/*.fnl", true},
    -- This will only compile init.fnl, all other fnl/ files will behave as normal.
    -- Or you could enable other patterns too,
    -- {"colors/*.fnl", true},
    -- {"fnl/**/*.fnl", true},
  }
}
