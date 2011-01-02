require 'active_record'

module ByStar
  def by_year(year=Time.now.year, options = {})
    beginning_of_year = Date.strptime("#{year}-01-01", "%Y-%m-%d").beginning_of_year
    end_of_year = beginning_of_year.end_of_year
    field = options[:field] || by_star.field || "created_at"
    where(self.arel_table[field].in(beginning_of_year..end_of_year))
  end
  
  def by_star(&block)
    @config ||= ByStar::Config.new
    @config.instance_eval(&block) if block_given?
    @config
  end
  
  class Config
    def field(value=nil)
      @field = value if value
      @field
    end
  end
end

ActiveRecord::Base.extend ByStar
