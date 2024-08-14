# _plugins/details_tag.rb

module Jekyll
    module Tags
      class DetailsTag < Liquid::Block
  
        def initialize(tag_name, markup, tokens)
          super
          @caption = markup
        end
  
        def render(context)
          site = context.registers[:site]
          converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
          # below Jekyll 3.x use this:
          # converter = site.getConverterImpl(::Jekyll::Converters::Markdown)
          caption = converter.convert(@caption).gsub(/<\/?p[^>]*>/, '').chomp
          body = converter.convert(super(context))
          "<details><summary style=\"font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;\">#{caption}</summary>#{body}</details>"
        end
  
      end
    end
  end
  
  Liquid::Template.register_tag('details', Jekyll::Tags::DetailsTag)