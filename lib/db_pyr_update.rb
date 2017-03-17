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

  def historical_reps(file)
    puts file
  end

  def socials(file)
    puts file
  end

  def office_locations(file)
    puts file
  end
end
