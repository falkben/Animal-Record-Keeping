class Flight < ActiveRecord::Base
	
	belongs_to :bat
	belongs_to :user
	
	belongs_to :cage
	belongs_to :medical_problem
	belongs_to :species
  has_and_belongs_to_many :surgeries, :order => "time desc"
	
	validates_presence_of :bat, :date
  
  #run automatically through cron job
	def self.populate_daily_flight_logs
		today = Date.today
		
		bats = Bat.active
		for bat in bats
			if !bat.flown_on(today)
				if bat.cage.flight_cage
					flight=Flight.new
					flight.bat = bat
					flight.user = bat.cage.user
					flight.date = today
					flight.cage = bat.cage
					flight.save
				elsif bat.exempt_from_flight
					flight=Flight.new
					flight.bat = bat
					flight.user = bat.cage.user
					flight.date = today
					flight.exempt = true
					flight.note = 'Exempt'
					if bat.species.hibernating
						flight.species = bat.species
					end
					if bat.medical_problems.current.length > 0
						flight.medical_problem = bat.med_problem_current_first_one_only
					end
					if bat.has_surgeries
            print "bat.band"
						flight.has_surgery = true
            flight.surgeries = bat.surgeries
					end
          if bat.quarantine?
            flight.quarantine = true
          end
					flight.save
				end
			end
		end
    return
	end
end