module HtmlHelper
  
  require 'set'

  # Simplified port of rails ActionView::Helpers:TagHelper

  BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked).to_set
  #BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map(&:to_sym))

  AUTO_TAGS = %w(br, img, hr)
  AUTO_CONTENT_TAGS = %w(h1, h2, h3, h4, h5, h6, p, div, ul, li)

  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}"
  end


  def content_tag(name, content = nil, options = nil, escape = true)
    tag_options = tag_options(options, escape) if options
    "<#{name}#{tag_options}>#{content}</#{name}>"
  end


  def tag_options(options, escape = true)
    unless options.blank?
      attrs = []
      if escape
        options.each_pair do |key, value|
          if BOOLEAN_ATTRIBUTES.include?(key)
            attrs << %(#{key}="#{key}") if value
          else
            attrs << %(#{key}="#{value}") if !value.nil?
          end
        end
      else
        attrs = options.map { |key, value| %(#{key}="#{value}") }
      end
      " #{attrs.sort * ' '}" unless attrs.empty?
    end
  end

  # Create dynamic methods for all listed tags in order to do
  # h1('foo') instead of content_tag('h1', 'foo')
  AUTO_CONTENT_TAGS.each do |tag|
    define_method(tag) do |*args|
      content_tag(tag, *args)
    end
  end


  AUTO_TAGS.each do |tag_name|
    define_method(tag_name) do |*args|
      tag(tag_name, *args)
    end
  end
  
  
  def stylesheets(stylesheets)
    link_tags = ''

    stylesheets.each do |stylesheet|
      stylesheet = "/assets/css/#{stylesheet}" unless stylesheet =~ /^\//
      stylesheet = "#{stylesheet}.css" unless stylesheet =~ /\.css$/
      link_tags += tag('link', {:rel => 'stylesheet', :href => stylesheet})
    end
    
    return link_tags
  end
  
  
  def php_includes(includes)
    unless includes.empty?
      return "<?php require_once('#{includes.join("', '")}') ?>"
    end
  end
  
  
  def sidebar_class
    return @item[:sidebar] ? 'has_sidebar ' : ''
  end

end


class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end