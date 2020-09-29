#!/usr/bin/env ruby

# Copyright 2020 SUSE
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'open3'
require 'yaml'

EXCLUDE = ENV.fetch('EXCLUDE', '').
            lines.
            map(&:strip).
            reject(&:empty?)

git_root, status = Open3.capture2('git', 'rev-parse', '--show-toplevel')
raise 'Could not get git root path' unless status.success?

Dir.chdir git_root.chomp do
  action_files = Dir.glob(File.join('**', 'action.{yml,yaml}'))
  EXCLUDE.each do |exclude|
    action_files -= Dir.glob(exclude)
  end
  action_files.each do |action_file|
    STDERR.puts "Processing //#{action_file}..."

    yaml = YAML.load_file(action_file)

    readme_file = File.join(File.dirname(action_file), 'README.md')
    File.open(readme_file, "w") do |f|
      title = yaml["name"]
      f << "# #{title}\n\n"

      description = yaml["description"]
      f << "#{description}\n\n"

      f << "## Inputs\n\n"
      inputs = yaml["inputs"]
      unless inputs.empty?
        f << "| Name | Description | Required | Default |\n"
        f << "| --- | --- | --- | --- |\n"
        inputs.each do |name, input|
          description = input["description"].gsub(/\s+/, ' ')
          required = input["required"]
          default = "`#{input["default"]}`" unless input["default"].nil? || input["default"].empty?
          f << "| #{name} | #{description} | #{required} | #{default} |\n"
        end
      else
        f << "This action has no inputs.\n"
      end
      f << "\n"

      f << "## Outputs\n\n"
      outputs = yaml["outputs"]
      unless outputs.empty?
        f << "| Name | Description |\n"
        f << "| --- | --- |\n"
        outputs.each do |name, output|
          description = output["description"].gsub(/\s+/, ' ')
          f << "| #{name} | #{description} |\n"
        end
      else
        f << "This action has no outputs.\n"
      end
    end
  end
end
