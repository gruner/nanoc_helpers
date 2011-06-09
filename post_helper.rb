module PostHelper
  
  # Adds extra meta data to post pages
  def add_post_attributes
    items.each do |item|
      if item[:filename] =~ /_posts/
        add_post_data item
      end
    end
  end
  
  def add_post_data(item)
    fname = File.basename(item[:filename], File.extname(item[:filename]))
    
    # get the date from the filename
    year, month, day = fname.split("-", 4)[0..2]
    
    # Strip the date from the filename
    item[:slug] = fname.sub(/^\d+-\d+-\d+-/,'')

    # Set creation date param from the values in the filename
    item[:created_at] = Time.local(year, month, day)

    # Add additional meta data
    item[:year] = year
    item[:month] = month
    item[:kind] = 'article'
    item[:comments] = true unless item[:comments] === false
  end
  
  # Returns n number of recent posts
  # TODO: add current post option, and remove it from the returned list
  def recent_posts(count=5)
    @sorted_articles ||= sorted_articles

    return @sorted_articles[0, count-1]
  end
  
  def pretty_time(time)
    time.strftime(@config[:date_format]) if !time.nil?
  end
  
  def month_day(time)
    time.strftime("%m/%d") if !time.nil?
  end
  
  # Don't show '.html' in generated links
  # we're hiding the extension with .htaccess
  def permalink(item)
    url = url_for(item)
    url.gsub!(/\.html$/, '') #if url[0].chr == "/"
    
    return url
  end
  
  # Use the filename as the slug
  def slugify(item)
    slug = File.basename(item[:filename], File.extname(item[:filename]))
    slug.gsub(/\s+/, '-')
  end
  
  # Returns a string of links to tag index pages,
  # optionally omits the given section
  def post_tags(item, section=nil)
    tags = []
    item[:tags].each do |tag|
      unless section == tag
        tags << content_tag('a', tag, {:href => '/' + tag.downcase})
      end
    end
    
    return tags.join(', ')
  end
  
  # Creates an id out of the page slug
  # that disqus uses for an id
  # TODO: nothing currently makes sure they're unique
  def disqus_id(item)
    id = 'fb_'
    id += item[:slug] ? item[:slug] : slugify(item)
    id.gsub(/-/, '_')
  end
  
  #=> { 2011 => { 12 => [item0, item1], 3 => [item0, item2]}, 2010 => {12 => [...]}}
  def articles_by_year_month
    result = {}
    current_year = current_month = year_h = month_a = nil

    sorted_articles.each do |item|
      d = item[:created_at]
      if current_year != d.year
        current_month = nil
        current_year = d.year
        year_h = result[current_year] = {}
      end

      if current_month != d.month
        current_month = d.month
        month_a = year_h[current_month] = [] 
      end

      month_a << item
    end

    result
  end
end
