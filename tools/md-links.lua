-- Rewrites relative links to .md files into links to the generated .html pages,
-- keeping any #fragment or ?query. Absolute URLs (http:, https:, mailto:) are left alone.
function Link(el)
  local t = el.target
  if t:match("^%a[%w+.-]*:") or t:match("^//") then return nil end
  local path, rest = t:match("^([^#?]*)(.*)$")
  if path:match("%.md$") then
    el.target = path:gsub("%.md$", ".html") .. rest
    return el
  end
end
