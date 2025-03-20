require 'rails_helper'

RSpec.describe Api::UsersController, type: :request do
  let(:valid_attributes) do
    {
      name: 'John',
      last_name: 'Doe',
      login: 'johndoe',
      email: 'john@example.com',
      phone_number: '1234567890',
      password: 'password',
      parameters: {}
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      last_name: nil,
      login: nil,
      email: nil,
      phone_number: nil,
      password: nil,
      parameters: {}
    }
  end

  let(:user) { create(:user) } # Используем FactoryBot для создания пользователя


  describe 'GET #index' do
    it 'returns an error message' do
      get '/api/users'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'мы не показываем список всех пользователей' })
    end
  end


  describe 'GET #show' do
    context 'with valid token' do
      before do
        # Устанавливаем токен в заголовке
        post '/api/users/authorization', params: { login: user.login, password: user.password }
        token = JSON.parse(response.body)['token']
        headers = { 'Authorization' => token }
      end

      it 'returns the user' do
        get "/api/users/#{user.uuid}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['uuid']).to eq(user.uuid)
      end
    end

    context 'with invalid token' do
      before do
        # Устанавливаем невалидный токен в заголовке
        request.headers['Authorization'] = 'invalid_token'
        allow(controller).to receive(:check_token).and_return(false) # Мокаем проверку токена
      end

      it 'returns an error message' do
        get "/api/users/#{user.uuid}"
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'неправильный токен' })
      end
    end
  end

=begin
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new user' do
        expect {
          post '/api/users', params: { user: valid_attributes }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('John')
      end
    end

    context 'with invalid params' do
      it 'returns an error message' do
        post '/api/users', params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity) # Исправляем ожидаемый статус
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Ошибка в параметрах пользователя' })
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = 'valid_token'
        allow(controller).to receive(:check_token).and_return(true) # Мокаем проверку токена
      end

      it 'updates the user' do
        put "/api/users/#{user.uuid}", params: { user: { name: 'Updated Name' } }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = 'invalid_token'
        allow(controller).to receive(:check_token).and_return(false) # Мокаем проверку токена
      end

      it 'returns an error message' do
        put "/api/users/#{user.uuid}", params: { user: { name: 'Updated Name' } }
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'неправильный токен' })
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid token' do
      before do
        request.headers['Authorization'] = 'valid_token'
        allow(controller).to receive(:check_token).and_return(true) # Мокаем проверку токена
      end

      it 'destroys the user' do
        delete "/api/users/#{user.uuid}"
        expect(response).to have_http_status(:no_content)
        expect(User.find_by_uuid(user.uuid)).to be_nil
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = 'invalid_token'
        allow(controller).to receive(:check_token).and_return(false) # Мокаем проверку токена
      end

      it 'returns an error message' do
        delete "/api/users/#{user.uuid}"
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'неправильный токен' })
      end
    end
  end

=end

  describe 'POST #authorization' do
    context 'with valid credentials' do
      it 'returns a token' do
        post '/api/users/authorization', params: { login: user.login, password: user.password }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message' do
        post '/api/users/authorization', params: { login: 'invalid', password: 'invalid' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'no_this_user' })
      end
    end
  end
end