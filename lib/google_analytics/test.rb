module GoogleAnalytics
  class Test
    extend Garb::Model
    metrics  :pageviews, :unique_pageviews
  end
end
