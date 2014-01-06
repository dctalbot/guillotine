class Item < ActiveRecord::Base
  has_many :rewards, :inverse_of => :item
  has_many :pledgers, :through => :rewards
  attr_accessible :backorderable, :cost, :name, :note, :shape, :stock, :taxable_value

  validates :cost, :name, :shape, :stock, :taxable_value, :presence => true
  validates :cost, :taxable_value, :numericality => { :greater_than => 0 }
  validates :stock, :numericality => { :only_integer => true, :greater_than_or_equal => 0 }
  validates :shape, :inclusion => { :in => %w{box flat shirt sweatshirt incorporeal}, :message => "Must be a valid shape" }

  def self.for_select(total_donation)
    #total_donation = 1_000_000 if user_is_dd?
    not_sold_out = []
    active.sort_by{|i| i.cost}.reject{|i| i.cost >= total_donation}.each { |i| 
      numleft = i.get_stock
      not_sold_out.push([i,numleft])
    }
    not_sold_out.map { |i,numleft|
      [i.name + (numleft > 0 ? " — #{numleft} left" : " — Backordered") + " ($%.2f)" % i.cost, i.id]
    }
  end

  def self.active
    where("backorderable = 't' or stock > 0").order(:name)
  end
  def self.inactive
    where("backorderable = 'f' and stock <= 0").order(:name)
  end

  def get_stock
    stock - rewards.where("premia_sent = 'false'").count
  end
end
