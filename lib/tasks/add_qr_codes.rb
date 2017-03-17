# frozen_string_literal: true

namespace :pyr do
  namespace :qr_codes do
    desc 'Generate QR code images for all office locations'
    task :generate do
      OfficeLocation.all.each { |o| o.add_qr_code_img }
    end
  end
end
