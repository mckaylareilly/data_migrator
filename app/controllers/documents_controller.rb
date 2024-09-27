class DocumentsController < ApplicationController
    def new
      @document = Document.new
    end
  
    def create
      uploaded_file = params[:document][:file]
      @document = Document.new(
        file_name: uploaded_file.original_filename, 
        status: 'pending', 
        upload_start: Time.current)
  
      if @document.save
        ProcessDocumentJob.perform_now(@document.id, uploaded_file)
      else
        render :new
      end
    end
  
    def index
      @documents = Document.all
    end
  end