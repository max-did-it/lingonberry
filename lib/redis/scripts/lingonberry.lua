#!lua name=lingonberry

function to_kwargs(keys, argv)
  local kwargs = {};
  for i,key in ipairs(keys) do 
    kwargs[key] = argv[i]
  end
  return kwargs
end

-- join keys with argv to table to restore **kwargs
function string_search(keys, args)
  local kwargs = to_kwargs(keys, argv)

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
end

redis.register_function('string_search', string_search)
