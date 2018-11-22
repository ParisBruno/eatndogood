module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # TODO: make normal connect
    def connect; end
    
    def disconnect; end
    
    private

    def find_current_user
      if current_user
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
