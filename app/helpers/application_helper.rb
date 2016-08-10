# frozen_string_literal: true

# Provides general application helper methods for HAML views
module ApplicationHelper
  def cancel
    url = URI.parse(request.referer.to_s).path.blank? ? root_path : URI.parse(request.referer.to_s).path
    link_to 'Cancel', url, class: 'btn btn-default'
  end

  def cancel_mini
    url = URI.parse(request.referer.to_s).path.blank? ? root_path : URI.parse(request.referer.to_s).path
    link_to 'Cancel', url, class: 'btn btn-xs btn-default'
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.is_a?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.zone.now - past_time)
    color = if seconds_ago < 60.minutes then '#6DD1EC'
            elsif seconds_ago < 1.day then '#ADDD1E'
            elsif seconds_ago < 2.days then '#CEDC34'
            elsif seconds_ago < 1.week then '#CEDC34'
            elsif seconds_ago < 1.month then '#DCAA24'
            elsif seconds_ago < 1.year then '#C2692A'
            else '#AA2D2F'
            end
    "<span style='color:#{color};font-weight:bold;font-variant:small-caps;\
    '>#{time_ago_in_words(past_time)} ago</span>".html_safe
  end

  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Time.zone.today
      past_time.strftime('at %I:%M %p')
    elsif past_time.year == Time.zone.today.year
      past_time.strftime('on %b %d at %I:%M %p')
    else
      past_time.strftime('on %b %d, %Y at %I:%M %p')
    end
  end

  def display_status(status)
    result = ''
    case status
    when 'published'
      result = "<span class='label label-success'>Published</span>"
    when 'submitted'
      result = "<span class='label label-success'>Submitted</span>"
    when 'nominated'
      result = "<span class='label label-info'>SC Approved</span>"
    when 'approved'
      result = "<span class='label label-info'>P&amp;P Approved</span>"
    when 'proposed'
      result = "<span class='label label-warning'>Proposed</span>"
    when 'draft'
      result = "<span class='label label-warning'>Draft</span>"
    when 'not approved'
      result = "<span class='label label-danger'>Not Approved</span>"
    end
    result.html_safe
  end

  def th_sort_field_rev(order, sort_field, display_name, extra_class: '')
    sort_params = params.permit(:search)
    sort_field_order = (order == "#{sort_field} desc" || order == "#{sort_field} desc nulls last") ? sort_field : "#{sort_field} desc"
    if order == sort_field
      selected_class = 'sort-selected'
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = 'sort-selected'
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: 'text-decoration:none' do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  def th_sort_field(order, sort_field, display_name, extra_class: '')
    sort_params = params.permit(:search)
    sort_field_order = (order == sort_field) ? "#{sort_field} desc" : sort_field
    if order == sort_field
      selected_class = 'sort-selected'
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = 'sort-selected'
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: 'text-decoration:none' do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  def simple_check(checked)
    checked ? '<span class="glyphicon glyphicon-ok"></span>'.html_safe : ''
  end
end
