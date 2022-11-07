require 'redis'
require 'ffaker'
require 'benchmark'
require 'securerandom'

script = <<-LUA
local keys = redis.call('KEYS', ARGV[1])
local matches_keys = {}
for _, key in pairs(keys) do
  local value = redis.call('GET', key)
  if string.find(value, ARGV[2]) then
    matches_keys[#(matches_keys) + 1] = key
  end
end
return matches_keys
LUA

$conn = Redis.new

def seed
  $conn.keys("test:*").each { |k| $conn.del k }
  text = ["Что нибудь новенькое в этом сезоне?
  Что нибудь новенькое из осенней коллекции?
  И как вам новый стиль?",
  "С чем носить?
  Какие цвета?
  Какой верх?",
  "А какой низ?
  Всем привет!
  Сегодня я к вам с новым набором.
  Он состоит из двух новых платьев.
  Это первое платье, которое мне нравится из новой коллекции.",
  "Оно мне напоминает платье из коллекции прошлого года
  Очаровательное платье с красивым декором и цветочным принтом!
  Всем доброго времени суток!
  Продолжаю свою серию отзывов о покупках в интернет-магазинах.",
  "Как нибудь в воскресение
  Прилетит из Киева
  Наша русская сестра
  И с собою привезёт
  Нам с тобою в понедельник
  Нечего делать в воскресенье
  Выпьем мы по рюмочке
  Поболтаем о разном",
  "Сядем мы на лавочку
  Да пойдём в кабак
  Я тебе налью винца
  Но не очень много
  Разговаривать будем
  О делах насущных",
  "Кто нам больше нужен
  Муж, жена или подруга
  Ты мне скажешь правду
  А я тебя спрошу
  Хочешь ли ты замуж
  Или просто так со мной гужуешь
  В понедельник с утра
  Мы пойдем на работу
  Там мы будем вместе
  На работе нет работы"
  ]
  100.times do
    $conn.set("test:#{SecureRandom.uuid}", text[rand(0..6)])
  end
end

$text_pattern = "Прилетит из Киева"
$pattern = "test:*"
$text_pattern_ruby = /Прилетит из Киева/

def string_search
  keys = $conn.keys($pattern)
  keys.map do |key|
    $conn.get(key).match($text_pattern_ruby) ? key : nil
  end.compact
end

$lua = $ruby = nil
seed
$sha = $conn.script(:load, script)
sleep(1)
Benchmark.bmbm do |x|
  x.report("lua") { $lua = $conn.evalsha $sha, argv: [$pattern, $text_pattern] }
  x.report("ruby") { $ruby = string_search }
end
puts "result is equel? #{$lua == $ruby}"

$conn.flushall

# Rehearsal ----------------------------------------
# lua    0.000170   0.000016   0.000186 (  0.000375)
# ruby   0.000656   0.009852   0.010508 (  0.011786)
# ------------------------------- total: 0.010694sec

#            user     system      total        real
# lua    0.000186   0.000000   0.000186 (  0.000383)
# ruby   0.008793   0.000000   0.008793 (  0.009774)
# result is equel? true
