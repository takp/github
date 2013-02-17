# encoding: utf-8

module Github

  # A module that decorates response with pagination helpers
  module Pagination
    include Github::Constants

    # Return page links
    def links
      @links = Github::PageLinks.new(env[:response_headers])
    end

    # Retrive number of total pages base on current :per_page parameter
    def count_pages
      page_iterator.count.to_i
    end

    # Iterator like each for response pages. If there are no pages to
    # iterate over this method will return current page.
    def each_page
      yield self
      while page_iterator.has_next?
        yield next_page
      end
    end

    # Retrives the result of the first page. Returns <tt>nil</tt> if there is
    # no first page - either because you are already on the first page
    # or there are no pages at all in the result.
    def first_page
      first_request = page_iterator.first
      self.instance_eval { @env = first_request.env } if first_request
      first_request
    end

    # Retrives the result of the next page. Returns <tt>nil</tt> if there is
    # no next page or no pages at all.
    def next_page
      next_request = page_iterator.next
      self.instance_eval { @env = next_request.env } if next_request
      next_request
    end

    # Retrives the result of the previous page. Returns <tt>nil</tt> if there is
    # no previous page or no pages at all.
    def prev_page
      prev_request = page_iterator.prev
      self.instance_eval { @env = prev_request.env } if prev_request
      prev_request
    end
    alias :previous_page :prev_page

    # Retrives the result of the last page. Returns <tt>nil</tt> if there is
    # no last page - either because you are already on the last page,
    # there is only one page or there are no pages at all in the result.
    def last_page
      last_request = page_iterator.last
      self.instance_eval { @env = last_request.env } if last_request
      last_request
    end

    # Retrives a specific result for a page given page number.
    # The <tt>page_number</tt> parameter is not validate, hitting a page
    # that does not exist will return Github API error. Consequently, if
    # there is only one page, this method returns nil
    def page(page_number)
      request = page_iterator.get_page(page_number)
      self.instance_eval { @env = request.env } if request
      request
    end

    # Returns <tt>true</tt> if there is another page in the result set,
    # otherwise <tt>false</tt>
    def has_next_page?
      page_iterator.has_next?
    end

    private

    # Internally used page iterator
    def page_iterator # :nodoc:
      @page_iterator = Github::PageIterator.new(links, current_api)
    end

  end # Pagination
end # Github