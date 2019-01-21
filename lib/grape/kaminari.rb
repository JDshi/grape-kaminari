require "grape"
require "grape/kaminari/version"
require "grape/kaminari/max_value_validator"
require "kaminari/grape"

module Grape
  module Kaminari
    def self.included(base)
      base.class_eval do
        helpers do
          def paginate(collection)
            page_collection = collection.page(params[:page].to_i).per(params[:per_page].to_i).padding(params[:offset].to_i)
            # page_collection.tap do |data|
              return [page_collection, {
                'pagination': {
                  'X-Total': page_collection.total_count.to_s,
                  'X-Total-Pages': page_collection.total_pages.to_s,
                  'X-Per-Page': page_collection.limit_value.to_s,
                  'X-Page': page_collection.current_page.to_s,
                  'X-Next-Page': page_collection.next_page.to_s,
                  'X-Prev-Page': page_collection.prev_page.to_s,
                  'X-Offset': params[:offset].to_s
                 }
             }]
            # end
          end
        end

        def self.paginate(options = {})
          options.reverse_merge!(
            per_page: ::Kaminari.config.default_per_page || 10,
            max_per_page: ::Kaminari.config.max_per_page,
            offset: 0
          )
          params do
            optional :page,     type: Integer, default: 1,
                                desc: 'Page offset to fetch.'
            optional :per_page, type: Integer, default: options[:per_page],
                                desc: 'Number of results to return per page.',
                                max_value: options[:max_per_page]
            if  options[:offset].is_a? Numeric
              optional :offset, type: Integer, default: options[:offset],
                                desc: 'Pad a number of results.'
            end
          end
        end
      end
    end
  end
end
