class RabbitListener
  def subscribe
    @connection = Bunny.new('amqp://guest:guest@rabbitmq', automatically_recover: true)
    @connection.start
    @channel = @connection.create_channel
    
    queue = @channel.queue('py_to_ruby', durable: true)
    
    queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, payload|
      begin
        process_message(payload)
        @channel.ack(delivery_info.delivery_tag)
      rescue => e
        Rails.logger.error "Error processing message: #{e.message}\n#{e.backtrace.join("\n")}"
        @channel.nack(delivery_info.delivery_tag, requeue: false)
      end
    end

  rescue Bunny::TCPConnectionFailed => e
    Rails.logger.error "RabbitMQ connection failed: #{e.message}"
    sleep 5
    retry
  end

  def process_message(payload)
    data = JSON.parse(payload)
    Rails.logger.debug "Received message: #{data}"
    user = User.find_by_uuid(data['user_id'])
    raise "User not found" unless user
    if data['gun'].present?
      last_shot = { message_id: data['message_id'], gun_id: data['gun']['id'], gun_name: data['gun']['name']}
      Rails.logger.info last_shot
      old_params = user.parameters || {}
      user.update!(parameters: old_params.merge({last_shot: last_shot}))
      gun = Gun.find(data['gun']['id'].to_i)
      gun.update!(shot_count: gun.shot_count + 1)
    end
    secret_gun = Gun.find(data['secret_gun'].to_i).delete
  end

  def delete
    @connection.close
    super
  end
end

