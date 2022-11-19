-- join keys with argv to table to restore **kwargs
local kwargs = {};
for i,key in ipairs(KEYS) do 
  kwargs[key] = ARGV[i]
end

-- scan keys and then match the values
local cursor = 0
  local matches_keys = {}
  repeat
    local founded_keys
    cursor, founded_keys  = redis.call('SCAN', cursor, kwargs.key_pattern)
    for i = 1, #founded_keys do
      local value = redis.call('GET', key)
      if string.find(value, kwargs.text_pattern) then
        table.insert(matches_keys, founded_keys[i])
      end
    end
  until (cursor == "0")

  return matches_keys
  