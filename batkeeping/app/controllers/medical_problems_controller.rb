class MedicalProblemsController < ApplicationController
  def index
    redirect_to :action => 'list_current'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    render :action => 'list'
  end

  def list_current
    @bats = Bat.sick
    @list_all = false
    list
  end

  def list_all
    @bats = Bat.sick_or_previously_sick
    @list_all = true
    list
  end
  
  def show
    @medical_problem = MedicalProblem.find(params[:id])
  end

  def new
    @medical_problem = MedicalProblem.new
    @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
    @deactivating = false
  end

  def remote_new_medical_problem
    bats = Bat.find(params[:bats])
    @users = User.find(:all, :conditions => "end_date is null and id != 1 and id != 3", :order => "name")
    render :partial=>'remote_new_medical_problem', :locals=>{:bats=>bats}
  end

  def remote_create
    bats = Bat.find(params[:bats])
    @medical_problem = MedicalProblem.new(params[:medical_problem])
    @medical_problem.date_closed = nil
    @medical_problem.date_opened = Time.now
    @medical_problem.bat = bats[0]
    @medical_problem.save
    render :partial=>'medical_problems/show_medical_problems', :locals=>{:bats => bats, :show_bat => false}
  end
  
  def create
    @bat = Bat.find(params[:bat][:id])
    @medical_problem = MedicalProblem.new(params[:medical_problem])
    @medical_problem.date_closed = nil
    @medical_problem.bat = @bat
    if @medical_problem.save
      flash[:notice] = 'Medical problem was successfully created.'
      redirect_to :controller => 'tasks', :action => 'new_medical_task', :id => @medical_problem
    else
      render :action => 'new'
    end
  end

  def edit
    @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
    @medical_problem = MedicalProblem.find(params[:id])
    @deactivating = false
  end

  def update
    @medical_problem = MedicalProblem.find(params[:id])
    @deactivating = params[:deactivating]
    if @medical_problem.update_attributes(params[:medical_problem])
      if @deactivating
          for task in @medical_problem.tasks.current
            task.date_ended = @medical_problem.date_closed
            task.save
          end
      end
      flash[:notice] = 'Medical Problem was successfully updated.'
    else
      render :action => 'edit'
    end
	  if params[:redirectme] == 'list_current'
		redirect_to :action => 'list_current'
	  else
		redirect_to :action => 'show', :id => @medical_problem
	  end
  end

  def destroy
    MedicalProblem.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def deactivate
	@medical_problem = MedicalProblem.find(params[:id])
  @bats = Bat.find(:all, :conditions => "leave_date is null", :order => "band")
  @deactivating = true
  end
  
  def reactivate
    @medical_problem = MedicalProblem.find(params[:id])
    @medical_problem.date_closed = nil
    @medical_problem.save
    redirect_to :action => 'list'
  end
end
