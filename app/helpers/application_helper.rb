module ApplicationHelper

  def cancel
    link_to image_tag('icons/cross.png', :alt => '') + 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), :class => 'button negative'
  end

  def print_byte_size(numbytes)
    return "" if numbytes == nil
    return "#{pluralize(numbytes, "byte")}" if numbytes / 1.kilobyte == 0
    return "#{pluralize("%0.1f" % (numbytes / 1.0.kilobyte), "kilobyte")} " if numbytes / 1.megabyte == 0
    return "#{pluralize("%0.1f" % (numbytes / 1.0.megabyte), "megabyte")}" if numbytes / 1.gigabyte == 0
    return "#{pluralize("%0.1f" % (numbytes / 1.0.gigabyte), "gigabyte")}" if numbytes / 1.terabyte == 0
    return "#{pluralize("%0.1f" % (numbytes / 1.0.terabyte), "terabyte")}"
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time
    seconds_ago = (Time.now - past_time)
    if seconds_ago < 60.minute then "<span style='color:#6DD1EC;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.minute).to_i, 'minute')} ago </span>".html_safe
    elsif seconds_ago < 1.day then "<span style='color:#ADDD1E;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.hour).to_i, 'hour')} ago </span>".html_safe
    elsif seconds_ago < 2.day then "<span style='color:#CEDC34;font-weight:bold;font-variant:small-caps;'>yesterday </span>".html_safe
    elsif seconds_ago < 1.week then "<span style='color:#CEDC34;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.day).to_i, 'day')} ago </span>".html_safe
    elsif seconds_ago < 1.month then "<span style='color:#DCAA24;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.week).to_i, 'week')} ago </span>".html_safe
    elsif seconds_ago < 1.year then "<span style='color:#C2692A;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.month).to_i, 'month')} ago </span>".html_safe
    else "<span style='color:#AA2D2F;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.year).to_i, 'year')} ago </span>".html_safe
    end
  end

  def simple_time(past_time)
    if past_time.to_date == Date.today
      past_time.strftime("at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end

end
