class ProtocolHistory < ActiveRecord::Base
	belongs_to :bat
  belongs_to :protocol
  has_one :bat_change
  belongs_to :user
	
	def self.todays_histories
    start_date=Date.today
    end_date=Date.today + 1.day
    hists = find(:all,
      :conditions => ["((added is true and date >= ? and date < ?) or (added is false and date >= ? and date < ?))",start_date,end_date,start_date,end_date])
    hists = hists.sort_by{|h| h.bat.band}
    return hists
  end
  
  def self.removed
    find :all, :conditions => 'added is false'
  end
  
  def after_save
    bat_change = BatChange.new
    bat_change.protocol_history = self
		bat_change.date = self.date.to_date
		bat_change.bat = self.bat
		bat_change.user = self.user
		bat_change.save
  end
  
  def self.populate_users
    for p_hist in ProtocolHistory.all
      #migrate users to protocol_histories (take the bat's cage owner - best we can do?)
      p_hist.user = ((p_hist.bat).in_cage_when(p_hist.date.to_date)).user
      p_hist.save
    end
  end
end