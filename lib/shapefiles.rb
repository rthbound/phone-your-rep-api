# frozen_string_literal: true
require_relative '../config/environment.rb'

class Shapefiles
  attr_reader :file

  def initialize(dir:, shp_file:)
    @file = Rails.root.join('lib', 'shapefiles', dir, shp_file).to_s
  end

  def import_shapefile(model:, model_attr:, record_attr:)
    RGeo::Shapefile::Reader.open(file, factory: Geographic::FACTORY) do |file|
      puts "File contains #{file.num_records} records."
      file.each do |record|
        add_record(model, model_attr, record, record_attr)
      end
    end
  end

  def add_record(model, model_attr, record, record_attr)
    puts "Record number #{record.index}:"
    record.geometry.projection.each do |poly|
      model.create(model_attr => record.attributes[record_attr],
                   :geom      => poly)
    end
    puts record.attributes
  end
end

StateGeom.destroy_all
DistrictGeom.destroy_all

shapefiles = Shapefiles.new dir: 'us_states_122116', shp_file: 'cb_2015_us_state_500k.shp'
shapefiles.import_shapefile(model:       StateGeom,
                            model_attr:  :state_code,
                            record_attr: 'STATEFP')

shapefiles = Shapefiles.new dir: 'us_congress_districts_122116', shp_file: 'cb_2015_us_cd114_500k.shp'
shapefiles.import_shapefile(model:         DistrictGeom,
                            model_attr:    :full_code,
                            record_attr:   'GEOID')
