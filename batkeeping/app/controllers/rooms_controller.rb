class RoomsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @room_pages, @room = paginate :rooms, :per_page => 10
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(params[:rooms])
    if @room.save
      flash[:notice] = 'Rooms was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(params[:rooms])
      flash[:notice] = 'Room was successfully updated.'
      redirect_to :action => 'show', :id => @room
    else
      render :action => 'edit'
    end
  end

  def destroy
    Room.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
