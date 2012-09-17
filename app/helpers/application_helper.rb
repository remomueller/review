module ApplicationHelper

  def cancel_mini
    link_to 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), class: 'btn btn-mini'
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.kind_of?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.now - past_time)
    color = if seconds_ago < 60.minute then "#6DD1EC"
    elsif seconds_ago < 1.day then "#ADDD1E"
    elsif seconds_ago < 2.day then "#CEDC34"
    elsif seconds_ago < 1.week then "#CEDC34"
    elsif seconds_ago < 1.month then "#DCAA24"
    elsif seconds_ago < 1.year then "#C2692A"
    else "#AA2D2F"
    end
    "<span style='color:#{color};font-weight:bold;font-variant:small-caps;'>#{time_ago_in_words(past_time)} ago</span>".html_safe
  end

  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Date.today
      past_time.strftime("at %I:%M %p")
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end

  def display_status(status)
    result = '<table class="status-table"><tr>'
    case status when 'published'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_marked proposed\" title=\"Proposed\">P</div></td><td><div class=\"status_marked approved\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_marked nominated\" title=\"SC Approved\">N</div></td><td><div class=\"status_marked submitted\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_marked published\" title=\"Published\">P</div></td>"
    when 'submitted'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_marked proposed\" title=\"Proposed\">P</div></td><td><div class=\"status_marked approved\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_marked nominated\" title=\"SC Approved\">N</div></td><td><div class=\"status_marked submitted\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_unmarked\" title=\"Published\">P</div></td>"
    when 'nominated'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_marked proposed\" title=\"Proposed\">P</div></td><td><div class=\"status_marked approved\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_marked nominated\" title=\"SC Approved\">N</div></td><td><div class=\"status_unmarked\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_unmarked\" title=\"Published\">P</div></td>"
    when 'approved'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_marked proposed\" title=\"Proposed\">P</div></td><td><div class=\"status_marked approved\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_unmarked\" title=\"SC Approved\">N</div></td><td><div class=\"status_unmarked\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_unmarked\" title=\"Published\">P</div></td>"
    when 'proposed'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_marked proposed\" title=\"Proposed\">P</div></td><td><div class=\"status_unmarked\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_unmarked\" title=\"SC Approved\">N</div></td><td><div class=\"status_unmarked\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_unmarked\" title=\"Published\">P</div></td>"
    when 'draft'
      result << "<td><div class=\"status_marked draft\" title=\"Draft\">D</div></td><td><div class=\"status_unmarked\" title=\"Proposed\">P</div></td><td><div class=\"status_unmarked\" title=\"P&amp;P Approved\">A</div></td><td><div class=\"status_unmarked\" title=\"SC Approved\">N</div></td><td><div class=\"status_unmarked\" title=\"Submitted for Publication\">S</div></td><td><div class=\"status_unmarked\" title=\"Published\">P</div></td>"
    when 'not approved'
      result << "<td><div class=\"status_marked not_approved\" title=\"Not Approved\">-</div></td>"
    end
    result << '</tr></table>'
    result.html_safe
  end

  def sort_field_helper_desc_only(order, sort_field, display_name, search_form_id  = 'search_form')
    "<span #{'class="selected"' if order.split(',').flatten.include?(sort_field + ' DESC')}>#{display_name} #{ link_to('&raquo;'.html_safe, '#', data: { object: 'order', order: "#{sort_field} DESC", form: "##{search_form_id}" }, style: 'text-decoration:none')}</span>"
  end

end
