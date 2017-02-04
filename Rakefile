# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task "missing_images" do
  file = File.read(Rails.root.join("lib/seeds/115-legislators-current-013117.yaml"))
  yaml = YAML.load(file)

  sizes = %w{ 450x550 225x275 }
  tmpls = "https://theunitedstates.io/images/congress/:size:/:bioguide_id:.jpg"

  missing = {
    "450x550" => [],
    "225x275" => [],
    "both"    => []
  }

  yaml.each do |entity|
    puts "Checking #{entity["id"]["bioguide"]}"
    presence = sizes.map do |size|
      sized_image_url = tmpls.gsub(/(:size:|:bioguide_id:)/, {
        ":size:"        => size,
        ":bioguide_id:" => entity["id"]["bioguide"]
      })

      puts "checking #{sized_image_url}"

      begin
        open(sized_image_url) # { |f| f.read }

        true
      rescue OpenURI::HTTPError => e
        false
      end
    end

    if presence.all?
      next
    elsif presence.none?
      missing["both"] << entity["id"]
    elsif !presence[0]
      missing[sizes[0]] << entity["id"]
    elsif !presence[1]
      missing[sizes[1]] << entity["id"]
    end
  end
  puts missing
end
