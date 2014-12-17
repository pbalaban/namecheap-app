module ApplicationHelper
  include Constants

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

  def external_link_to title, url
    icon = content_tag(:i, nil, class: 'fa fa-external-link')
    [title, link_to(icon, url, target: :_blank)].join(' ').html_safe
  end

  def external_link_to_categories_for domain
    domain.categories.map do |category|
      url = MARKETPLACE_BY_CATEGORY_URL.gsub(/%\w*%/, '%ID%' => category.remote_id)
      external_link_to category.name, url
    end.join(', ').html_safe
  end

  def external_link_to_user_for remote_user
    return nil if remote_user.blank?

    url = MARKETPLACE_BY_USER_URL.gsub(/%\w*%/, '%ID%' => remote_user)
    external_link_to remote_user, url
  end
end
