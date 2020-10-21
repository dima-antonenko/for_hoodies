module AdminHelper

  def pretty_datetime(datetime)
    datetime.to_s.chomp('UTC').chomp(' +0300')
  end

  def pretty_price(price)
    number_to_currency(price, precision: 0, delimiter: '', format: "%n %u" , :unit => '$')
  end

  def bool_to_string(value)
    if value
      I18n.t "all_pages.labels.yes_label"
    else
      I18n.t "all_pages.labels.no_label"
    end
  end

  def short_title(title, value)
    if title.size > value
      title[0...value] + ' ...'
    else
      title
    end
  end
end