# Enables smartypants option on RDiscount
class RDiscountSmartFilter < Nanoc3::Filter
  
  identifier :rdiscount_smart

  def run(content, params={})
    require 'rdiscount'

    ::RDiscount.new(content, :smart).to_html
  end

end