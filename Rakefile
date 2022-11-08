require_relative "lingonberry"
require "json"
namespace :redis do
  namespace :scripts do
    desc "Load scripts to redis and generate file with SHA names of the scripts"
    task :load do
      scripts_sha = []
      Lingonberry.connection do |connection|
        Dir["lib/redis/scripts/*"].each do |script_file|
          script = File.read script_file
          script_name = File.basename(script_file, ".lua")
          raise Lingonberry::Errors::ScriptExtensionIsNotLua, script_file.to_s unless script_name

          script_sha = connection.script(:load, script)
          scripts_sha.push([script_name.to_sym, script_sha])
          File.write("lib/redis/scripts_sha.json", scripts_sha.to_h.to_json)
        end
      end
    end
    desc "Generates modele"
    task :generate_module do
      require "erb"
      scripts_sha = JSON.parse(File.read("lib/redis/scripts_sha.json"), symbol_keys: true)
      template = ERB.new File.read("lib/redis/scripts_lib.rb.erb")
      lib = template.result(binding)
      File.write("lib/redis/scripts_lib.rb", lib)
    end

    desc "Remove all loaded scripts"
    task :flush do
    end
  end
end
