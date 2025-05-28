function define_color(varname, tex_macro_name)
  local value = os.getenv(varname)
  if not value then
    error("Environment variable " .. varname .. " is not set!")
  end
  tex.sprint("\\expandafter\\def\\csname " .. tex_macro_name .. "\\endcsname{" .. value .. "}")
end