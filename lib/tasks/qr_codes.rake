# frozen_string_literal: true

namespace :pyr do
  namespace :qr_codes do
    desc 'Generate QR code images for all office locations'
    task :generate do
      OfficeLocation.where(active: true).each { |o| o.add_qr_code_img }
    end

    desc 'Remove the image meta files'
    task :clean do
      if ENV['source_file']
        source_file = ENV['source_file']
      else
        month = Date.today.month.to_s
        day = Date.today.day.to_s
        m = month.length == 1 ? "0#{month}" : month
        d = day.length == 1 ? "0#{day}" : day
        y = Date.today.year.to_s
        source_file = Rails.root.join(
          'public/system/dragonfly/development', y, m, d
        )
      end
      Dir.chdir(source_file.to_s) do
        sh 'rm *meta.yml'
      end
    end
  end
end
