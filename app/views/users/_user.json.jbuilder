json.extract! user, :id, :name, :last_name, :login, :email, :phone_number, :password, :uuid, :parameters, :created_at, :updated_at
json.url user_url(user, format: :json)
