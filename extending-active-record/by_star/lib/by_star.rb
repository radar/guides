require 'active_record'

module ByStar
  def by_year(year=Time.now.year)
    beginning_of_year = Date.strptime("#{year}-01-01", "%Y-%m-%d").beginning_of_year
    end_of_year = beginning_of_year.end_of_year
    where(self.arel_table[:created_at].in(beginning_of_year..end_of_year))
  end
end

ActiveRecord::Base.extend ByStar
