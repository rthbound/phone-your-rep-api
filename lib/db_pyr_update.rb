# frozen_string_literal: true
require_relative '../config/environment'

class DbPyrUpdate
  def parse_yaml(file)
    YAML.load(File.open(file))
  end

  def reps(file)
    @yaml_reps = parse_yaml(file)
    @yaml_reps.each do |yaml_rep|
      db_rep = Rep.find_or_create_by(bioguide_id: yaml_rep['id']['bioguide'])
      update_rep(db_rep, yaml_rep)
    end
  end

  def update_rep(db_rep, yaml_rep)
    name = yaml_rep['name']
    term = yaml_rep['terms'].last
    db_rep.tap do |rep|
      update_rep_name(rep, name)
      update_rep_term_info(rep, term)
      update_rep_capitol_office(rep, term)
      update_rep_photo(rep)
      rep.active = true
    end
    db_rep.save
  end

  def update_rep_name(rep, name)
    rep.official_full = name['official_full']
    rep.first         = name['first']
    rep.middle        = name['middle']
    rep.last          = name['last']
    rep.suffix        = name['suffix']
    rep.nickname      = name['nickname']
  end

  def update_rep_term_info(rep, term)
    dis_code = format('%d', term['district']) if term['district']
    dis_code = dis_code.size == 1 ? "0#{dis_code}" : dis_code if dis_code
    rep.role = determine_current_rep_role(term)
    rep.state    = State.find_by(abbr: term['state'])
    rep.district = District.where(code: dis_code, state: rep.state).take
    rep.party         = term['party']
    rep.url           = term['url']
    rep.contact_form  = term['contact_form']
    rep.senate_class  = format('0%o', term['class']) if term['class']
  end

  def determine_current_rep_role(term)
    if term['type'] == 'sen'
      'United States Senator'
    elsif term['type'] == 'rep'
      'United States Representative'
    else
      term['type']
    end
  end

  def update_rep_capitol_office(rep, term)
    address_ary = term['address'].split(' ')
    cap_office  = rep.office_locations.find_or_create_by(office_type: 'capitol')
    cap_office.update(
      phone:   term['phone'],
      fax:     term['fax'],
      hours:   term['hours'],
      zip:     address_ary.pop,
      state:   address_ary.pop,
      city:    address_ary.pop,
      address: address_ary.
        join(' ').
        delete(';').
        sub('HOB', 'House Office Building')
    )
  end

  def update_rep_photo(rep)
    rep.photo = photo_slug(rep.bioguide_id)
  end

  def photo_slug(rep_bioguide_id)
    "https://theunitedstates.io/images/congress/450x550/#{rep_bioguide_id}.jpg"
  end

  def historical_reps(file)
    @historical_reps = parse_yaml(file)
    @historical_reps.each do |h_rep|
      rep = Rep.find_by(bioguide_id: h_rep['id']['bioguide'])
      next if rep.blank?
      rep.update(active: false)
    end
  end

  def socials(file)
    @socials = parse_yaml(file)
    @socials.each do |social|
      rep = Rep.find_or_create_by(bioguide_id: social['id']['bioguide'])
      update_rep_socials(rep, social)
      rep.save
    end
  end

  def update_rep_socials(rep, social)
    rep.facebook     = social['social']['facebook']
    rep.facebook_id  = social['social']['facebook_id']
    rep.twitter      = social['social']['twitter']
    rep.twitter_id   = social['social']['twitter_id']
    rep.youtube      = social['social']['youtube']
    rep.youtube_id   = social['social']['youtube_id']
    rep.instagram    = social['social']['instagram']
    rep.instagram_id = social['social']['instagram_id']
    rep.googleplus   = social['social']['googleplus']
  end

  def office_locations(file)
    puts file
  end
end
