module ApplicationHelper
  def winrate_color_class(winrate, prefix: 'progress--')
    rate = winrate.to_f

    suffix = if rate < 25
               'low'
             elsif rate <= 49
               'medium'
             else
               'high'
             end

    "#{prefix}#{suffix}"
  end
end
