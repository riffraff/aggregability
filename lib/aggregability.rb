# -*- encoding : utf-8 -*-
require "aggregability/version"
require 'pp' if $DEBUG
    def ipn key, xmlnode, *rest
      p [key, [xmlnode.name, xmlnode['id'], xmlnode['class']]] + rest
    end

module Aggregability
=begin
    def timeit str = 'timed:'
      start = Time.now
      res = yield
      p [str, Time.now - start] if $DEBUG
      res
    end
    # debugging printer
    def ipn key, xmlnode, *rest
      p [key, [xmlnode.name, xmlnode['id'], xmlnode['class']]] + rest
    end
=end


    Item = Struct.new(:title, :url, :scores, :comments_count) do

      def score
        scores.first
      end

      # for testing
      def to_hash
       hsh = Hash[each_pair.to_a]
       hsh[:score] = score
       hsh
      end

      # for the cli tool
      def to_row
        "Title: #{title}\nUrl: #{url}\nScores: #{scores.join(',')}\nComments: #{comments_count}"
      end
    end


  class Extractor

    attr :parser
    
    # init providing a root_url (so relative urls can be normalized)
    # such as "http://reddit.com" (no trailing slash
    #
    def initialize root_url="", xmlish_parser=nil
      # raise error to avoid messing up later with implict behaviour"
      raise 'root url should not contain a trailing slash' if root_url[-1] == ?/
      @root_url = root_url
      if xmlish_parser.nil?
        require 'nokogiri'
        @parser = Nokogiri::HTML::Document
      end
    end

    # could speed up things, but actually it's rather useless :)
    IGNOREABLE_CHILDREN_ELEMENTS = %w[
      script img button style
    ]

    # attempts to find all the items under a certain node that could be interesting for us
    # e.g. comments, titles, votes
    #
    def children_item_nodes node
      node.xpath(
                  *TITLE_NODE_SELECTORS,
                  *SCORE_NODE_SELECTORS,
                  *SUBMITTER_NODE_SELECTORS,
                  *COMMENTS_NODE_SELECTORS
                 ).reject {|n| IGNOREABLE_CHILDREN_ELEMENTS.include?(n.name) }
    end


    # Attempts to find the most probable "content" node given a set produced by +#children_item_nodes+
    #
    def closest_common_ancestor_for_most(cs)
      # see above for why this is needed
      cs = remove_nested_nodes(cs)
      ancestors_lists = cs.map {|x| x.ancestors}

      # find something that covers enough nodes
      # ancestors_lists = [[span, p, div0, html], [div2, div1, html], [div3, div1, html]]
      # best = [[div2, div1, html], [div3, div1, html]]
      best = ancestors_lists.group_by {|ancestors| ancestors.length}.max_by {|length,group| group.size}[1]
      #50%+1
      min_matching = (best.size / 2).ceil

      ancestors_lists.shift.zip(*ancestors_lists) do |same_level_ancestors|
        hsh = Hash.new(0)
        same_level_ancestors.each do |anc| 
          count = hsh[anc] += 1 
          return anc if hsh[anc] > min_matching
        end
      end
      nil
    end

    # Given a node set, remove the nodes which are included in the others, e.g
    # 
    # 
    #  item
    #    votes
    #    title
    #  item  
    #    votes
    #    title
    #
    # becomes
    #  item
    #  item
    #
    # This is necessary for +closest_common_ancestor_for_most+ to get the number right
    # because you may have a structure like
    #
    # body  
    #  header 
    #   title 
    #    title 
    #     title 
    #      title
    #  content 
    #   title
    #   title
    # and we don't want to screw up our estimation of what the real content page is
    #
    def remove_nested_nodes(nodes)
      # still slow, but seems fast enough, e.g. 0.01177 sec for reddit page, 0.07 for digg
      # assumes nodes are provided in the textual order of the page
      take = [nodes.shift]
      nodes.each do |this|
        # there is probably a faster way to do this I am currently not imagining
        # a.find {|e| b.include?(e)} is _much_ slower
        if (this.ancestors.to_a & take).empty?
          take << this
        end
      end
      take
    end

    # returns the most likely "content" element, whence we can extract the news
    # returns +nil+ if it can't find anything
    # or if the only candidate is +body+ itself
    #
    # Works by identifying possible interesting nodes (comments, scores, stories)
    # and then finding the element which contains the most
    #
    def find_content xmlnode
      raise "searching a nil node doesn't make sense" if xmlnode.nil?
      cs = children_item_nodes(xmlnode)
      #pp cs.map {|x| [x.name, x['id'], x['class'], x.ancestors.size ]}
      if cs.empty?
        return nil
      end
      anc = closest_common_ancestor_for_most(cs)
      if anc.nil? || anc.name == 'body'
        nil
      else
        anc
      end
    end

    # if xpath's match() method worked in nokogiri/libxml life would be better
    # sadly nokogiri's "add your own xpath functions" makes it super slow
    def self.concat_ignorecase_xpath_expr(text_expr, contained)
      chars = contained.chars.sort.join.squeeze
      "contains(translate(#{text_expr},'#{chars.upcase}','#{chars.downcase}'),'#{contained}')"
    end 



    # given something that looks like a "item" element, hod do you look for the link?
    TITLE_NODE_SELECTORS= ['.//h1//a', './/h2//a', './/h3//a', './/h4//a', './/h5//a', 
                           ".//*[contains(@class,'title')]/a",
                           ".//a[contains(@class,'title')]"
                          ]

    # actually wrong, could very well be a local url or a scheme dependent url
    # //foo.com
    TITLE_NODE_HARDER_SELECTORS= [".//a[starts-with(@href,'http')]"]

    # ditto, for stuff that may look like a score
    #
    # here reducing the number of selectors from 9 to 1 makes some speed difference.
    # and since I make many calls to them this improves the speed a bit.
    # Of course, not making the calls would be better, but this took one minute to write.
    #
    score_concat_exprs = %w[count point score vote].map do |n| 
      concat_ignorecase_xpath_expr("concat(text(),' ',@class)", n)
    end
    SCORE_NODE_SELECTORS = [
                          ".//*[#{score_concat_exprs.join(' or ')} or contains(text(),'up')]"
                           ]
    comment_concat_exprs = concat_ignorecase_xpath_expr("concat(text(),' ',@class)", 'comment')
    # comments are more restricted, cause I have no found other rules 
    # (though you may look for speech bubbles)
    COMMENTS_NODE_SELECTORS = [
                          ".//*[#{comment_concat_exprs}]"
                           ]

    SUBMITTER_NODE_SELECTORS = [
                          ".//*[contains(text(),'submitted')]",
                          ".//*[contains(text(),'posted')]",
                          ".//*[contains(text(),'submitted')]",
                           ]

    def title_node node
      nodes = node.xpath(*TITLE_NODE_SELECTORS)
      if nodes.empty?
        # try harder 
        nodes = node.xpath(*TITLE_NODE_HARDER_SELECTORS)
        if @root_url
          nodes = nodes.select {|n| n['href'].index(@root_url) != 0}
        end
      end
      nodes.first
    end

    SINGLE_SCORE_RGX =  /
                          \A
                          \d+
                          (?:
                            \s* 
                            (?:
                              votes? |
                              points?
                            ) 
                          |
                            \z
                          )
                          
                        /mix
    MULTIPLE_SCORE_RGX =  /
                            \A
                            (?: \d+ )
                            \s+
                            up
                            (?:
                              \s+
                              (?: and\s+ )?
                              \d+
                              \s+
                              down
                            )
                          /mix
    COMMENTS_COUNT_RGX =  /
                            \A
                            \d+
                            (?:
                              \s* 
                              (comments?) 
                            )?
                            \z
                          /mix

    def extract_score_nodes node
      # need to get the text nodes to avoid situations like counting 3 elements [votes, up, down] in 
      #
      # story
      #  votes
      #   up
      #    5
      #   down
      #    6 
       
      # shaves some time
      text_nodes = node.xpath(*SCORE_NODE_SELECTORS.map {|n| n+"//text()"})
      res = text_nodes.select do |text_node|
        text_node.text.strip =~  SINGLE_SCORE_RGX || text_node.text.strip =~ MULTIPLE_SCORE_RGX
      end
    end
    def comments_node(node)
      node.xpath(*COMMENTS_NODE_SELECTORS).select do |n| 
        n.text.strip =~  COMMENTS_COUNT_RGX
      end
    end

    def fix_url u
      case u 
      when %r{^https?://}
        u
      when %r{^/}
        "#{@root_url}#{u}"
      else
        "#{@root_url}/#{u}"
      end
    end

    def find_items_paired nodes
      nodes.map do |node| 
        
        title = title_node(node)
        if title.nil?
          next
        end
        title_s = title.text.to_s.strip
        title_u = title['href'].to_s.strip

        # look for score in an item paired with this one
        next_sibling = node.next
        #but if it has a title then ignore it
        if next_sibling && title_node(next_sibling)
          next_sibling = nil
        end

        scores = extract_score_nodes(node)
        if scores.empty? && next_sibling
          scores = extract_score_nodes(next_sibling)
        end
       
        comments_node = comments_node(node)
        if comments_node.empty? && next_sibling
          comments_node = comments_node(next_sibling)
        end
        # should be nil
        comments_count = (comments_node.first ? comments_node.first.text : 0).to_i
        Item.new(title_s, fix_url(title_u), scores.map {|x| x.text.to_i}, comments_count)
      end.compact


    end
    ITEM_HTML_ELEMENTS = %w[
      div article section li p dt dl dd ul ol tr td
    ]
    IGNOREABLE_TITLES = %w[
      more next prev succ
    ]
    def find_items container 
      # only the last condition has actually effect on the results
      # the others are still useful to filter out garbage e.g. interspersed <script> between <div> tags
      nodes = container.children.select do |i| 
        #p [i.name, i['class'], i.ancestors.map(&:name), !i.text.strip.empty?, i.text.strip]
        ITEM_HTML_ELEMENTS.include?(i.name) && 
        !i.text.strip.empty? &&
        !IGNOREABLE_TITLES.include?(i.text.downcase.strip)
      end
      find_items_paired nodes
    end    

    # Extracts Items from IO, you can specify an encoding if necessary, but utf-8 by default is a sensible choice
    #
    def parse_io(io, encoding='utf-8')
      # possibly this could make some difference, but none I can see 
      # opts = ParseOptions::COMPACT |  ParseOptions::DEFAULT_HTML | ParseOptions::NOBLANKS | ParseOptions::NONET

      # we could offset directly to 'body'.. but 'body' is not there sometimes :)
      xmlnode = parser.parse(io, @root_url, encoding)
      content_node = find_content(xmlnode)
      items = find_items(content_node)
    rescue RuntimeError => e
      if e.message == "xmlXPathTranslateFunction: Invalid UTF8 string\n" && encoding
        if io.is_a? String
          encoding = nil
          retry
        elsif io.respond_to? :rewind
          io.rewind
          encoding = nil
          retry
        end
      end
    end

  end

end
