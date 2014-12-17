module ApplicationHelper
  def date_tooltip_for date
    return nil if date.blank?

    opts = { toggle: :tooltip, title: date.strftime('%I:%M %p') }
    content_tag(:span, date.strftime('%b %d, %Y'), data: opts)
  end

  def date_closing_tooltip_for date
    return nil if date.blank?
    return date_tooltip_for(date) if date > 1.day.since

    if date < 1.hour.since
      opts = { toggle: :tooltip, title: date.strftime('%I:%M %p') }
      content_tag(:span, time_ago_in_words(date), data: opts)
    else
      opts = { toggle: :tooltip, title: 'Today' }
      content_tag(:span, date.strftime('%I:%M %p'), data: opts)
    end
  end
end
