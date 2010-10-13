class <%= controller_class_name %>Controller < ApplicationController
  respond_to :html, :xml, :json
  load_resource :except => [:create]
  authorize_resource
  
  def index
    params[:page] ||= 1
    
    @<%= plural_table_name %> = @<%= plural_table_name %>.paginate(:page => params[:page], :per_page => 10)
    bwi_respond_with(@<%= plural_table_name %>)
  end

  def show
    bwi_respond_with(@<%= singular_table_name %>)
  end

  def new
    bwi_respond_with(@<%= singular_table_name %>)
  end

  def edit
    bwi_respond_with(@<%= singular_table_name %>)
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>
    if @<%= orm_instance.save %>
      flash[:notice] = '<%= human_name %> was successfully created.'
    end
    bwi_respond_with(@<%= singular_table_name %>)
  end

  def update
    if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
      flash[:notice] = '<%= human_name %> was successfully updated.'
    end
    bwi_respond_with(@<%= singular_table_name %>)
  end

  def destroy
    @<%= orm_instance.destroy %>
    bwi_respond_with(@<%= singular_table_name %>)
  end
end
