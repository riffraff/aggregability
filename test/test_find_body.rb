# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TestFindContent < Test::Unit::TestCase
  def test_find_content_basic
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(s=<<-HTML)
      <html>
        <body>
          <div dummy>
              #{'<div><a class="title dummy">title</a></div>'*2}
          </div>
          <div id="content">
            #{'<div class="title"><a class="title">title</a></div>'*5}
          </div>
        </body>
      </html>
    HTML
    b = e.find_content xml
    assert_equal  'content', b['id']
  end

  def test_find_content_with_header
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(<<-HTML)
    <html>
      <body>
        <div id="header"></div>
        <div id="content">
          #{'<div><a class="title">title</a></div>'*10}
        </div>
      </body>
    </html>
    HTML

    b = e.find_content xml
    assert_equal  'content', b['id']
  end

  def test_find_content_with_deep_tags
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(<<-HTML)
      <html>
      <head>
      </head>
      <body>
        <div id="header">
          <a tabindex="1" href="#content" id="jumpToContent" name="jumpToContent">jump to
          content</a>
        </div>
        <div class="side">
          <div class="spacer">
            <form action="http://www.reddit.com/search" id="search" name="search">
              <input type="text" name="q" placeholder="search reddit">
              <div id="searchexpando" class="infobar">
                <div id="moresearchinfo">
                  <a href="#" id="search_hidemore" name="search_hidemore">[-]</a>
                  <p>use the following search parameters to narrow your results:</p>
                  <dl>
                    <dt>reddit:{name}</dt>
                    <dd>find things posted in {name} only</dd>
                    <dt>author:{username}</dt>
                    <dd>return things submitted by {username} only</dd>
                    <dt>site:{domain}</dt>
                    <dd>get links to pages on {domain} only</dd>
                    <dt>url:{text}</dt>
                    <dd>search for {text} in url</dd>
                    <dt>selftext:{text}</dt>
                    <dd>search for {text} in self post contents</dd>
                    <dt>is_self:{yes|no}</dt>
                    <dd>include or exclude self posts</dd>
                    <dt>over18:{yes|no}</dt>
                    <dd>include or exclude results from nsfw reddits</dd>
                  </dl>
                  <p>e.g.<code>reddit:pics site:imgur.com dog</code></p>
                  <p><a href="http://www.reddit.com/help/search">see the search faq for
                  details.</a></p>
                </div>
                <p><a href="http://www.reddit.com/help/search" id="search_showmore" name=
                "search_showmore">advanced search: by author, community...</a></p>
              </div>
            </form>
          </div>
        </div><a name="content" id="content"></a>
        <div id="content">
          <div class="infobar">
            <div class="md">
              <p>reddit is a source for what's new and popular online. vote on links that you
              like or dislike and help decide what's popular, or submit your own!</p>
            </div>
          </div>
          #{'<div><a class="title">title</a></div>'*10}
        </div>
      </body>
      </html>

  HTML
    b = e.find_content xml
    assert_equal  'content', b['id']
  end

  def test_find_content_mini_reddit_1
    str = File.read 'test/data/mini_reddit_1.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    n  = b
    assert_equal  'div', b.name
    assert_equal  'sitetable linklisting', b['class']
    assert_equal  'siteTable', b['id']
  end

  def test_find_content_reddit
    str = File.read 'test/data/reddit.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'div', b.name
    assert_equal  'sitetable linklisting', b['class']
    assert_equal  'siteTable', b['id']
  end

  def test_find_content_mini_newsyc 
    str = File.read 'test/data/mini_news.ycombinator.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'table', b.name
    assert_equal  nil, b['class']
    assert_equal  nil, b['id']
    assert_equal  nil, b['bgcolor']
  end

  def test_find_content_newsyc 
    str = File.read 'test/data/news.ycombinator.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'table', b.name
    assert_equal  nil, b['class']
    assert_equal  nil, b['id']
    assert_equal  nil, b['bgcolor']
  end
  def test_find_content_hackful
    str = File.read 'test/data/hackful.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'div', b.name
    assert_equal  'body', b['class']
    assert_equal  nil, b['id']
  end
end
