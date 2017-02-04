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

  yaml.each do |entity|
    presence = sizes.map do |size|
      sized_image_url = tmpls.gsub(/(:size:|:bioguide_id:)/, {
        ":size:"        => size,
        ":bioguide_id:" => entity["id"]["bioguide"]
      })

      curl = Curl::Easy.http_get(sized_image_url)
      !!curl.header_str.match(/HTTP\/1.1 200 OK/)
    end
    row = "#{entity["name"]["first"]} #{entity["last"]}"

    if presence.all?
      next
    elsif presence.none?
      puts "#{row},1,1"
    elsif !presence[0]
      puts "#{row},1,0"
    elsif !presence[1]
      puts "#{row},0,1"
    end
  end
end
