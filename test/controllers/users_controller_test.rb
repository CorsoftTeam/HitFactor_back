require 'test_helper'

RSpec.describe 'Api::UsersController', type: :request do
  path '/users' do
    get 'Получить сообщение об ошибке (список пользователей недоступен)' do
      tags 'Пользователи'
      produces 'application/json'

      response '200', 'Сообщение об ошибке получено' do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: %w[error]

        run_test! do
          get '/users'
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['error']).to eq('мы не показываем список всех пользователей')
        end
      end
    end
  end

  path '/users/{id}' do
    get 'Получить информацию о пользователе' do
      tags 'Пользователи'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'UUID пользователя'

      response '200', 'Пользователь найден' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            email: { type: :string },
            uuid: { type: :string }
          },
          required: %w[id name email uuid]

        let(:user) { create(:user) }
        let(:id) { user.uuid }

        run_test! do
          get "/users/#{id}"
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['uuid']).to eq(user.uuid)
        end
      end

      response '404', 'Пользователь не найден' do
        let(:id) { 'invalid_uuid' }

        run_test! do
          get "/users/#{id}"
          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)['error']).to eq('Пользователь не найден')
        end
      end
    end
  end

  path '/users' do
    post 'Создать пользователя' do
      tags 'Пользователи'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          last_name: { type: :string },
          login: { type: :string },
          email: { type: :string },
          phone_number: { type: :string },
          password: { type: :string },
          parameters: { type: :object }
        },
        required: %w[name login email password]
      }

      response '201', 'Пользователь создан' do
        let(:user) do
          {
            name: 'John',
            last_name: 'Doe',
            login: 'johndoe',
            email: 'john@example.com',
            phone_number: '1234567890',
            password: 'password',
            parameters: { key: 'value' }
          }
        end

        run_test! do
          expect { post '/users', params: { user: user } }.to change(User, :count).by(1)
          expect(response).to have_http_status(201)
          expect(JSON.parse(response.body)['name']).to eq('John')
        end
      end

      response '401', 'Ошибка в параметрах пользователя' do
        let(:user) { { name: 'John' } } # Недостаточно параметров

        run_test! do
          post '/users', params: { user: user }
          expect(response).to have_http_status(401)
          expect(JSON.parse(response.body)['error']).to eq('Ошибка в параметрах пользователя')
        end
      end
    end
  end

  path '/users/{id}' do
    put 'Обновить информацию о пользователе' do
      tags 'Пользователи'
      consumes 'application/json'
      # parameter name: :id, in: :path, type: :string, description: 'UUID пользователя'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          last_name: { type: :string },
          email: { type: :string },
          phone_number: { type: :string },
          password: { type: :string },
          parameters: { type: :object }
        }
      }

      response '200', 'Пользователь обновлен' do
        let(:user) { create(:user) }
        let(:id) { user.uuid }
        let(:new_name) { 'Updated Name' }

        run_test! do
          put "/users/#{id}", params: { user: { name: new_name } }
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['name']).to eq(new_name)
        end
      end

      response '403', 'Неправильный токен' do
        let(:user) { create(:user) }
        let(:id) { user.uuid }

        run_test! do
          put "/users/#{id}", params: { user: { name: 'New Name' } }
          expect(response).to have_http_status(403)
          expect(JSON.parse(response.body)['error']).to eq('неправильный токен')
        end
      end
    end
  end

  path '/users/{id}' do
    delete 'Удалить пользователя' do
      tags 'Пользователи'
      parameter name: :id, in: :path, type: :string, description: 'UUID пользователя'

      response '204', 'Пользователь удален' do
        let(:user) { create(:user) }
        let(:id) { user.uuid }

        run_test! do
          delete "/users/#{id}"
          expect(response).to have_http_status(204)
        end
      end

      response '403', 'Неправильный токен' do
        let(:user) { create(:user) }
        let(:id) { user.uuid }

        run_test! do
          delete "/users/#{id}"
          expect(response).to have_http_status(403)
          expect(JSON.parse(response.body)['error']).to eq('неправильный токен')
        end
      end
    end
  end

  path '/authorization' do
    post 'Авторизация пользователя' do
      tags 'Пользователи'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          login: { type: :string },
          password: { type: :string }
        },
        required: %w[login password]
      }

      response '200', 'Токен создан' do
        let(:user) { create(:user, login: 'johndoe', password: 'password') }
        let(:credentials) { { login: 'johndoe', password: 'password' } }

        run_test! do
          post '/authorization', params: credentials
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)['token']).not_to be_nil
        end
      end

      response '401', 'Пользователь не найден' do
        let(:credentials) { { login: 'invalid', password: 'invalid' } }

        run_test! do
          post '/authorization', params: credentials
          expect(response).to have_http_status(401)
          expect(JSON.parse(response.body)['error']).to eq('no_this_user')
        end
      end
    end
  end
end