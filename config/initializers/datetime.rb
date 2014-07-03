#Time::DATE_FORMATS[:dob] = "%d %B %Y"
#Time::DATE_FORMATS[:standard] = "%d %b %Y"
#Time::DATE_FORMATS[:standard_with_time] = "%d %b %Y %H:%M"
#Time::DATE_FORMATS[:standard_with_week_day] = "%A %d %b %Y"
#Time::DATE_FORMATS[:excel] = "%Y-%m-%dT%H:%M:%S.000"
#Time::DATE_FORMATS[:calendar] = "%d/%m/%Y"
#Time::DATE_FORMATS[:ols_status] = "%d/%m/%Y %H:%M"

#Time::DATE_FORMATS[:detailed] = "%Y-%m-%d %a %H:%M:%S"

#Time::DATE_FORMATS[:long] = lambda { |date| date.strftime("#{date.day.ordinalize} %B %Y") }
#Date::DATE_FORMATS[:long] = lambda { |date| date.strftime("#{date.day.ordinalize} %B %Y") }


[Time, Date].each do |const|
  const::DATE_FORMATS[:calendar] = -> (date){ date.strftime("%A, #{date.day.ordinalize} %B %Y") }
end
