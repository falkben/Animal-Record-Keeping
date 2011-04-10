class MyMailer < ActionMailer::Base

  def mail(recipient, msg_subject, msg_body)
    from "batkeeping@zoopsych2-63.umd.edu"
    recipients recipient
    subject msg_subject
    body :email_body => msg_body
  end
  
  def mass_mail(recipients, msg_subject, msg_body)
    from "batkeeping@zoopsych2-63.umd.edu"
    recipients recipients
    subject msg_subject
    body :email_body => msg_body
  end
	
	def self.create_msg_for_bats_not_weighed(bats)
		if bats.length > 0
			msg_body = "The following bats have not been weighed in at least 1 week:\n"
			for bat in bats
				msg_body = msg_body + "\nBat: " + bat.band
        msg_body = msg_body + "\nCage: " + bat.cage.name
				msg_body = msg_body + "\nOwner: " + bat.cage.user.name
				msg_body = msg_body + "\nLast weigh date: " + bat.weights.recent.date.strftime("%a, %b %d, %Y") + "\n"
			end
			msg_body = msg_body + "\n*******************************************\n\n"
			return msg_body
		else
			return ''
		end
	end

  def self.create_msg_for_protocol_changes(phs)
    if phs.length > 0
      msg_body = "The following protocol changes were made:\n"
      for ph in phs
        bat = ph.bat
        if ph.date_removed != nil
          rel_text = "Removed from protocol:"
        else
          rel_text = "Added to protocol:"
        end
        msg_body = msg_body + "\n#{rel_text}"
        msg_body = msg_body + "\nBat: " + bat.band
        if bat.cage != nil
          msg_body = msg_body + "\nCage: " + bat.cage.name
          msg_body = msg_body + "\nOwner: " + bat.cage.user.name
        end
        msg_body = msg_body + "\n Title: " + ph.protocol.title
        msg_body = msg_body + "\n Number: " + ph.protocol.number + "\n"
      end
      msg_body = msg_body + "\n*******************************************\n\n"
			return msg_body
    else
			return ''
		end
  end
	
	def self.create_msg_for_tasks_not_done(tasks_not_done)
		if tasks_not_done.length > 0
      msg_body = "This is a warning email to notify you that the following tasks were not completed:\n\n"
      for task in tasks_not_done
        msg_body = msg_body + "Task: " + task.title
				if task.room
					msg_body = msg_body + "\nRoom: " + task.room.name
				end
				if task.medical_treatment
					msg_body = msg_body + "\nBat: " + task.medical_treatment.medical_problem.bat.band
					msg_body = msg_body + "\nMedical Problem: " + task.medical_treatment.medical_problem.title
					msg_body = msg_body + "\nMedical Problem Description: " + task.medical_treatment.medical_problem.description
				end
				msg_body = msg_body + "\nAssigned to: " 
        if (task.users.length > 0)
          for user in task.users
            msg_body = msg_body + user.name
						if user != task.users.last
							msg_body = msg_body + ", "
						end
          end
        else
          msg_body = msg_body + "Animal Care Staff"
        end
        msg_body = msg_body + "\n\n"
      end
    else
      msg_body = "All of today's tasks completed.\n\n"
    end
		
		msg_body = msg_body + "*******************************************\n\n"
		
		return msg_body
	end
	
	def self.email_users
	  for user in User.current
			if !user.administrator?
        #per user generated email minus admins
        users_tasks = user.tasks.today
        
        if ((user.animal_care_user? && ( (Time.now.wday == 1) || (Time.now.wday == 2) || (Time.now.wday == 3) || (Time.now.wday == 4) || (Time.now.wday == 5))) || (user.weekend_care_user? && (Time.now.wday == 6 || Time.now.wday == 0)))
          Task.animal_care_user_general_tasks_today.each{|task| users_tasks << task}
          Task.animal_care_user_feeding_tasks_today.each{|task| users_tasks << task}
        end
        
        if user.medical_care_user?
          Task.medical_user_tasks_today.each{|task| users_tasks << task}
        end
        
        users_tasks_not_done = Task.tasks_not_done_today(users_tasks)
        users_bats_not_weighed = Bat.not_weighed(user.bats)
        
        if (users_tasks_not_done.length > 0) || (users_bats_not_weighed.length > 0)
          greeting = "Hi " + user.name + ",\n\n"
          greeting = greeting + Time.now.strftime('%A, %B %d, %Y') + "\n\n"
          msg_body = MyMailer.create_msg_for_tasks_not_done(users_tasks_not_done)
          msg_body = msg_body + MyMailer.create_msg_for_bats_not_weighed(users_bats_not_weighed)
          msg_body = msg_body + "Faithfully yours, etc."
          MyMailer.deliver_mail(user.email, "tasks not done today", greeting + msg_body)
        end
			end
		end
		
		#all administrators get CCed on one email and see everything
		admin_emails = Array.new
		User.administrator.each{|admin| admin_emails << admin.email}
		
		tasks_not_done = Task.tasks_not_done_today(Task.today)
    bats_not_weighed = Bat.not_weighed(Bat.active)
    protocol_changes = ProtocolHistory.todays_histories
    
		if (tasks_not_done.length > 0) || (bats_not_weighed.length > 0) || (protocol_changes.length > 0)
			greeting = "Administrator(s),\n\n"
      greeting = greeting + Time.now.strftime('%A, %B %d, %Y') + "\n\n"
			msg_body = MyMailer.create_msg_for_tasks_not_done(tasks_not_done)
      msg_body = msg_body + MyMailer.create_msg_for_bats_not_weighed(bats_not_weighed)
      msg_body = msg_body + MyMailer.create_msg_for_protocol_changes(protocol_changes)
			msg_body = msg_body + "Faithfully yours, etc."
			MyMailer.deliver_mass_mail(admin_emails, "tasks not done today", greeting + msg_body)
		end
	end
end