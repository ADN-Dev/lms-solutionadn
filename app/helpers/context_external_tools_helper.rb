module ContextExternalToolsHelper
  def external_tools_menu_items(tools, options={})
    markup = tools.map do |tool|
      external_tool_menu_item_tag(tool, options)
    end
    raw(markup.join(''))
  end

  def external_tool_menu_item_tag(tool, options={})
    defaults = {
      show_icon: true,
      in_list: false,
      url_params: {}
    }

    options = defaults.merge(options)
    url_params = options.delete(:url_params)

    if tool.respond_to?(:extension_setting)
      tool = external_tool_display_hash(tool, options[:settings_key], url_params)
    elsif !url_params.empty?
      # url_params were supplied, but we aren't hitting the url helper
      # we need to make sure the tool url includes the url_params
      parsed = URI.parse(tool[:base_url])
      parsed.query = Rack::Utils.parse_nested_query(parsed.query).merge(url_params).to_query
      tool[:base_url] = parsed.to_s
    end

    link_attrs =  {
      href: tool[:base_url]
    }

    link_attrs[:class] = options[:link_class] if options[:link_class]
    link = content_tag(:a, link_attrs) do
      concat(render(partial: 'external_tools/helpers/icon', locals: {tool: tool})) if options[:show_icon]
      concat(tool[:title])
      concat(external_tool_new_badge_tag) if tool[:is_new]
    end

    if options[:in_list]
      li_attrs = {
        role: "presentation",
        class: options[:settings_key]
      }
      link = content_tag(:li, li_attrs) { link }
    end

    raw(link)
  end

  def external_tool_new_badge_tag
      # <span class="badge new_badge pull-right"><%= t('links.new_badge', 'New') %></span>
      tag_attrs = {
        class: "badge new_badge pull-right"
      }

      content_tag(:span, tag_attrs) do
        t('New')
      end
  end
end
