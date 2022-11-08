-- join keys with argv to table to restore **kwargs
local kwargs = {};
for i,key in ipairs(KEYS) do 
  kwargs[key] = ARGV[i]
end

local keys = redis.call('KEYS', kwargs.key_pattern)
local matches_keys = {}
for _, key in pairs(keys) do
  local value = redis.call('GET', key)
  if string.find(value, kwargs.text_pattern) then
    matches_keys[#(matches_keys) + 1] = key
  end
end

return matches_keys
