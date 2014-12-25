module ApplicationHelper
  include Constants

  def date_tooltip_for date, extra_opts = {}
    return nil if date.blank?

    opts = { toggle: :tooltip, title: date.strftime('%I:%M %p %Z') }.merge(extra_opts)
    content_tag(:span, date.strftime('%b %d, %Y'), data: opts)
  end

  def date_closing_tooltip_for date
    return nil if date.blank?
    return date_tooltip_for(date) if date > 1.day.since.midnight

    if date < 1.hour.since
      opts = { toggle: :tooltip, title: date.strftime('%I:%M %p %Z') }
      content_tag(:span, time_ago_in_words(date), data: opts)
    else
      opts = { toggle: :tooltip, title: 'Today' }
      content_tag(:span, date.strftime('%I:%M %p %Z'), data: opts)
    end
  end

  def join_fa_icon content, icon_class, url = nil, link_opts = {}
    icon = content_tag(:i, nil, class: "fa #{icon_class}")
    link_or_icon = url ? link_to(icon, url, link_opts) : icon
    [content, link_or_icon].join(' ').html_safe
  end

  def external_link_to title, url
    join_fa_icon title, 'fa-external-link', url, target: :_blank
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

  def sortable_header_for attr
    title = Domain.human_attribute_name(attr)

    order_class = 'fa-sort'
    order_class << "-alpha-#{@search.order_dir}" if @search.order_attr.eql?(attr)

    url_params = (params[:domain_search] || {}).dup
    url_params.merge!(order_attr: attr)
    url_params.merge!(order_dir: @search.reverse_order_dir_for(attr))

    join_fa_icon title, order_class, root_path(domain_search: url_params)
  end
end
