class GamesController < ApplicationController
  
  def new
    render 'new'
  end
  
  def create
     creator = User.find_or_create_by(name: "PJ")
    @game = Game.create(creator_id: creator.id) 
    redirect_to @game    
  end
  
  def show
    @game = Game.find(params[:id])
  end
end
